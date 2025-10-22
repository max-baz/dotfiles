{ config, pkgs, ... }: {
  security.wrappers.jail-ai-ebpf-loader = {
    source = "${pkgs.jail-ai}/bin/jail-ai-ebpf-loader";
    capabilities = "cap_bpf,cap_net_admin+ep";
    owner = "root";
    group = "root";
    permissions = "0755";
  };

  home-manager.users.${config.user}.home.packages = with pkgs; [
    jail-ai
  ];
}
