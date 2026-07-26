{ pkgs, ... }: {
  home.packages = with pkgs; [
    bfs
    zsh
  ];
  home.file = {
    ".p10k-ascii-8color.zsh".source = ./zsh/.p10k.zsh;
    ".p10k.zsh".source = ./zsh/.p10k.zsh;
    ".zprofile".source = ./zsh/.zprofile;
    ".zsh-aliases".source = ./zsh/.zsh-aliases;
    ".zshenv".source = ./zsh/.zshenv;
    ".zshrc".source = ./zsh/.zshrc;
    ".zsh-extra".text = ''
      JQ_ZSH_PLUGIN_EXPAND_ALIASES=0
      z4h source -- ${pkgs.jq-zsh-plugin}/share/jq-zsh-plugin/jq.plugin.zsh
    '';
  };
}
