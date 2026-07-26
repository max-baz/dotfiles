{ config, ... }: {
  home.sessionVariables.DOCKER_CONFIG = "${config.xdg.configHome}/docker";
}
