{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    dbmate
    mariadb.client
    pgcli
    postgresql_18
  ];

  xdg.configFile."pgcli/config".text = ''
    [main]
    keyring = False
    table_format = double
    history_file = ${config.xdg.stateHome}/pgcli/history
    use_local_timezone = False
  '';
}
