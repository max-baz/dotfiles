{ lib, pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      curl
      git
      helix
      wget
    ];

    variables = {
      EDITOR = lib.getExe pkgs.helix;
      VISUAL = lib.getExe pkgs.helix;
    };
  };
}
