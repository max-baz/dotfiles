{ pkgs, ... }: {
  home.packages = with pkgs; [
    sleek-todo
    todo-txt-cli
  ];

  xdg.configFile."sleek/userData/customStyles.css" = {
    force = true;
    text = ''
      body,
      body * {
        font-family: "Open Sans", sans-serif !important;
      }

      body code,
      body code *,
      body pre,
      body pre *,
      body kbd,
      body samp {
        font-family: "Input", monospace !important;
      }
    '';
  };
}
