{ config, lib, pkgs, unstable-small, ... }: {
  home-manager.users.${config.user}.programs.mpv = {
    enable = true;
    scripts = lib.mkIf pkgs.stdenv.isLinux [
      pkgs.mpvScripts.mpris
      pkgs.mpvScripts.mpris
      pkgs.mpvScripts.uosc
      pkgs.mpvScripts.thumbfast
      pkgs.mpvScripts.sponsorblock
    ];
    config = {
      osc = false;
      osd-bar = false;
      hwdec = "auto";
      demuxer-max-back-bytes = 10000000000;
      demuxer-max-bytes = 10000000000;
      interpolation = true;
      video-sync = "display-resample";
      sub-visibility = false;
      sub-auto = "fuzzy";
      alang = "en,eng,da,dan";
      slang = "en,eng,da,dan";
      vlang = "en,eng,da,dan";
      save-position-on-quit = true;
      ignore-path-in-watch-later-config = true;
      ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";

      # default is now vulkan, but it doesn't work well on asahi on x265 / hdr videos
      # https://github.com/mpv-player/mpv/issues/16218
      gpu-api = "opengl";
    };
    scriptOpts = {
      uosc = {
        timeline_size = 25;
        timeline_persistency = "paused,audio";
        progress = "always";
        progress_size = 4;
        progress_line_width = 4;
        controls = "subtitles,<has_many_audio>audio,<has_many_video>video,<has_many_edition>editions,<stream>stream-quality";
        top_bar = "never";
        refine = "text_width";
      };
      thumbfast = {
        spawn_first = true;
        network = true;
        hwdec = true;
      };
      ytdl_hook = {
        ytdl_path = "${lib.getExe unstable-small.yt-dlp}";
      };
    };
    bindings = {
      mbtn_right = "script-binding uosc/menu";
      a = "script-binding uosc/stream-quality";
      c = "script-binding uosc/chapters";
      s = "script-binding uosc/subtitles";
    };
  };
}
