{ config, pkgs, unstable-small, ... }: {
  home-manager.users.${config.user} = { config, ... }: {
    home.packages = with pkgs; [
      cilium-cli
      k9s
      kubectl
      kubectl-cnpg
      kubectl-view-secret
      kubectx
      kubelogin
      kubelogin-oidc
      kubernetes-helm
      kubeseal
      kustomize
      stern
      unstable-small.talosctl
    ];

    sops.secrets."talosconfig".path = "${config.home.homeDirectory}/.talos/config";
  };
}
