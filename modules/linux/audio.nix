{ pkgs, ... }:
let
  wireplumber = pkgs.wireplumber.overrideAttrs {
    version = "0.5.15";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "pipewire";
      repo = "wireplumber";
      tag = "0.5.15";
      hash = "sha256-28JrX8V23VpTe6GPI6g/JlN7412yJLMcwEre2Jv77qg=";
    };
  };
in
{
  services.pipewire.wireplumber.package = wireplumber;
}
