{ config, lib, pkgs, unstable-small, ... }: {
  home.packages = with pkgs; [
    argocd
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

  programs.kubecolor.enable = true;

  sops.secrets."talosconfig" = lib.mkIf config.personal.enable {
    path = "${config.home.homeDirectory}/.talos/config";
  };
}
