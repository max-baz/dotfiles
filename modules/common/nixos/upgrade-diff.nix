{ config, pkgs, ... }: {
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        echo "#############################        diff to current-system        ##############################"
        echo "#                                                                                               #"
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff $(${pkgs.coreutils}/bin/readlink "/run/current-system") "$systemConfig" | tee /etc/gradientos-changelog
        echo "#                                                                                               #"
        echo "#############################      end diff to current-system      ##############################"
      fi
    '';
  };
}
