{ inputs, mkModuleArgs, ... }:
let
  system = "x86_64-linux";
  user = "max";
  moduleArgs = mkModuleArgs system;
in
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = moduleArgs;
  modules = [
    { inherit user; }
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.dell-xps-14-da14260
    inputs.sops-nix.nixosModules.sops
    inputs.dotfiles-private.nixosModules.linux
    inputs.home-manager.nixosModules.home-manager
    ../../modules/linux
    ../../modules/hardware/intel-graphics.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    ../../modules/hardware/secure-boot.nix
    (
      { config, lib, ... }:
      let
        ipu7Pkgs = import inputs.nixpkgs-ipu7 {
          inherit system;
          config.allowUnfree = true;
        };
        gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (
          with ipu7Pkgs.gst_all_1;
          [
            gstreamer.out
            gst-plugins-base
            gst-plugins-good
            gst-plugins-bad
            icamerasrc-ipu75xa
          ]
        );
        deviceFile = "/run/ipu7-camera-relay/device";
        input = "icamerasrc ! videoconvert ! videoscale ! videoflip method=vertical-flip";
        output =
          "appsrc name=appsrc caps=video/x-raw,format=YUY2,width=1280,height=720,framerate=30/1"
          + " ! queue leaky=downstream max-size-buffers=3 ! videoconvert ! v4l2sink name=v4l2sink device=$(cat ${deviceFile}) sync=false";
      in
      {
        boot.extraModulePackages = [
          (config.boot.kernelPackages.callPackage "${inputs.nixpkgs-ipu7}/pkgs/os-specific/linux/ipu7-drivers" { })
        ];

        hardware.firmware = [
          ipu7Pkgs.ipu7-camera-bins
          ipu7Pkgs.ivsc-firmware
        ];

        services.udev.extraRules = ''
          SUBSYSTEM=="intel-ipu7-psys", MODE="0660", GROUP="video"
        '';

        systemd.services.ipu7-camera-relay = {
          after = [ "gphoto2-v4l2loopback.service" ];
          description = lib.mkForce "Intel IPU7 camera to v4l2loopback relay (hardware ISP via camera HAL)";
          environment = {
            GST_PLUGIN_PATH = lib.mkForce gstPluginPath;
            LIBVA_DRIVER_NAME = "iHD";
            LIBVA_DRIVERS_PATH = "${ipu7Pkgs.intel-media-driver}/lib/dri";
          };
          script = lib.mkForce ''
            exec ${ipu7Pkgs.v4l2-relayd}/bin/v4l2-relayd -i "${input}" -o "${output}"
          '';
        };

        networking.hostName = "home-pika";

        home-manager = {
          extraSpecialArgs = moduleArgs;

          users.${user} = {
            personal.enable = true;

            imports = [
              inputs.sops-nix.homeManagerModules.sops
              inputs.nix-index-database.homeModules.nix-index
            ];
          };
        };
      }
    )
  ];
}
