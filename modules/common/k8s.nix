{ config, pkgs, ... }: {
  home-manager.users.${config.user}.home.packages = with pkgs; [
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
  ];
}
