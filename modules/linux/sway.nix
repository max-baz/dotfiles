{ config, lib, pkgs, ... }: {
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  home-manager.users.${config.user}.wayland.windowManager.sway =
    let
      workspace1 = "workspace number 1";
      workspace2 = "workspace number 2";
      workspace3 = "workspace number 3";
      workspace4 = "workspace number 4";
      workspace5 = "workspace number 5";
      workspace6 = "workspace number 6";
      workspace7 = "workspace number 7";
      workspace8 = "workspace number 8";
      workspace9 = "workspace number 9";
      workspace10 = "workspace number 10";
    in
    {
      package = null;
      enable = true;
      xwayland = true;
      systemd.enable = true;

      # can't discover my custom layout
      checkConfig = false;

      extraConfig = ''
        set $screen_laptop 'Apple Computer Inc Color LCD Unknown'
        bindswitch --locked lid:off output $screen_laptop dpms on
        bindswitch --locked lid:on  output $screen_laptop dpms off, exec brightnessctl set -d kbd_backlight 0

        default_border pixel 2
        default_floating_border none
        hide_edge_borders --i3 none
        tiling_drag disable

        # Specific window configuration
        for_window    [app_id=".*"]                              sticky enable
        for_window    [app_id="signal"]                          move container to ${workspace3}
        for_window    [app_id="aerc"]                            move container to ${workspace4}
        for_window    [app_id="dmenu.*"]                         floating enable, resize set width 60ppt height 80ppt
        for_window    [app_id="dmenu-browser"]                   resize set height 20ppt
        for_window    [app_id="dmenu-emoji"]                     resize set height 20ppt
        for_window    [app_id="mpv"]                             resize set width 500, move position 1000 30
        for_window    [app_id="thunderbird" title=".*Reminder"]  floating enable, resize set width 480 height 140, move position 1035 735

        set $mode_audio "Audio"
        mode $mode_audio {
            bindsym --to-code {
                h exec audio bt-connect-headset, mode "default"
                s exec audio bt-connect-speakers, mode "default"
                t exec audio bt-toggle-profile, mode "default"
                d exec audio bt-disconnect, mode "default"

                # back to normal: Enter or Escape
                Return mode default
                Escape mode default
            }
        }

        set $mode_resize "Resize window"
        mode $mode_resize {
            bindsym --to-code {
                h            exec swaymsg resize grow   left 10 || swaymsg resize shrink right 10
                Ctrl+h       exec swaymsg resize grow   left 1  || swaymsg resize shrink right 1
                j            exec swaymsg resize shrink up   10 || swaymsg resize grow   down  10
                Ctrl+j       exec swaymsg resize shrink up   1  || swaymsg resize grow   down  1
                k            exec swaymsg resize grow   up   10 || swaymsg resize shrink down  10
                Ctrl+k       exec swaymsg resize grow   up   1  || swaymsg resize shrink down  1
                l            exec swaymsg resize shrink left 10 || swaymsg resize grow   right 10
                Ctrl+l       exec swaymsg resize shrink left 1  || swaymsg resize grow   right 1

                # back to normal: Enter or Escape
                Return mode default
                Escape mode default
            }
        }

        set $mode_system "System exit"
        mode $mode_system {
            bindsym --to-code {
                e exec exit-wm tty, mode "default"
                l exec exit-wm lock, mode "default"
                s exec exit-wm suspend, mode "default"
                r exec exit-wm reboot, mode "default"
                h exec exit-wm shutdown, mode "default"

                # back to normal: Enter or Escape
                Return mode default
                Escape mode default
            }
        }

        set $mode_workspaces_monitors "Move workspace between monitors"
        mode $mode_workspaces_monitors {
            bindsym --to-code {
                h exec swaymsg move workspace to output left, mode "default"
                l exec swaymsg move workspace to output right, mode "default"

                # back to normal: Enter or Escape
                Return mode default
                Escape mode default
            }
        }
      '';

      config = {
        input = {
          "type:keyboard" = {
            xkb_layout = "us,ua";
            xkb_options = "grp:shifts_toggle,compose:ralt,numpad:mac";
            xkb_numlock = "enable";
            repeat_delay = "300";
            repeat_rate = "60";
          };

          "type:touchpad" = {
            natural_scroll = "enabled";
            tap = "enabled";
            click_method = "button_areas";
          };
        };

        seat."*".hide_cursor = "10000";
        output."*".bg = "#1a1c1c solid_color";

        gaps = {
          inner = 5;
          smartGaps = true;
        };

        window.hideEdgeBorders = "none";

        focus = {
          wrapping = "yes";
          mouseWarping = false;
          followMouse = false;
        };

        workspaceLayout = "tabbed";

        bars = [ ];

        colors =
          let
            color_normal_white = "#a89984";
            color_bright_white = "#ebdbb2";
            color_normal_gray = "#282828";
            color_bright_gray = "#3c3836";
            color_bright_yellow = "#d79921";
            color_normal_black = "#1d2021";
            color_unused = "#ff0000";
          in
          {
            focused = {
              border = color_bright_gray;
              background = color_bright_gray;
              text = color_bright_white;
              indicator = color_bright_gray;
              childBorder = color_normal_black;
            };
            focusedInactive = {
              border = color_bright_gray;
              background = color_bright_gray;
              text = color_bright_white;
              indicator = color_bright_gray;
              childBorder = color_normal_black;
            };
            unfocused = {
              border = color_normal_gray;
              background = color_normal_gray;
              text = color_normal_white;
              indicator = color_normal_gray;
              childBorder = color_normal_black;
            };
            urgent = {
              border = color_bright_yellow;
              background = color_bright_yellow;
              text = color_normal_black;
              indicator = color_unused;
              childBorder = color_unused;
            };
            placeholder = {
              border = color_unused;
              background = color_unused;
              text = color_unused;
              indicator = color_unused;
              childBorder = color_unused;
            };
          };

        floating = {
          criteria = [
            { window_role = "pop-up"; }
            { app_id = "udiskie"; }
            { app_id = "dmenu.*"; }
            { app_id = "qalculate-gtk"; }
            { app_id = "mpv"; }
          ];
          modifier = "Mod4";
        };

        bindkeysToCode = true;
        keybindings = let win = "Mod4+Alt"; hyper = "Mod4"; in {
          # Terminal
          "${hyper}+Return" = "exec cglaunch --term";
          "${hyper}+XF86MonBrightnessDown" = "exec cglaunch --term";
          "${win}+Return" = "exec kitty --config NONE";
          "${win}+Shift+Return" = "exec kitty --config NONE /bin/bash";

          # Launcher
          "${hyper}+equal" = "exec cgtoggle qalculate-gtk";
          "${hyper}+d" = "exec cgtoggle wldash";
          "${hyper}+n" = "exec cgtoggle network-dmenu";
          "${hyper}+p" = "exec 'wl-clipboard-manager lock; cglaunch passmenu -p pass; wl-clipboard-manager unlock'";
          "${win}+p" = "exec cgtoggle pass-gen";
          "${hyper}+m" = "exec cgtoggle udiskie-dmenu";
          "${hyper}+grave" = "exec cgtoggle wl-clipboard-manager dmenu";
          "${hyper}+Backspace" = "exec cgtoggle emoji-dmenu";
          "${hyper}+XF86MonBrightnessUp" = "exec cgtoggle emoji-dmenu";
          "${hyper}+Escape" = "exec cglaunch screenshot-area";
          "${win}+Escape" = "exec cglaunch record-area";
          "${win}+i" = "exec cglaunch ${lib.getExe pkgs.hyprpicker} -al";

          # Kill focused window
          "${win}+q" = "kill";

          # Change focus
          "${hyper}+h" = "focus left";
          "${hyper}+j" = "focus down";
          "${hyper}+k" = "focus up";
          "${hyper}+l" = "focus right";

          # Move focused window
          "${win}+h" = "move left";
          "${win}+j" = "move down";
          "${win}+k" = "move up";
          "${win}+l" = "move right";

          # Enter fullscreen mode
          "${hyper}+f" = "fullscreen";
          "${win}+f" = "exec pkill -USR1 waybar";

          # Container layout: split
          "${hyper}+e" = "layout toggle split";

          # Container layout: tabbed
          "${hyper}+w" = "layout tabbed";

          # Split
          "${hyper}+s" = "split toggle";

          # Focus the parent container
          "${hyper}+u" = "focus parent";

          # Focus the child container
          "${hyper}+i" = "focus child";

          # Toggle tiling / floating
          "${win}+space" = "floating toggle";

          # Make the currently focused window a scratchpad
          "${win}+minus" = "move scratchpad";

          # Show the first scratchpad window
          "${hyper}+minus" = "scratchpad show";

          # Change focus between tiling / floating windows
          "Alt+space" = "focus mode_toggle";

          # Notification actions
          "${hyper}+q" = "exec swaync-client --close-all";

          # Brightness control
          "${hyper}+F2" = "exec brightnessctl set -- +1%";
          "${hyper}+F1" = "exec brightnessctl set -- -1%";
          "${win}+F2" = "exec brightnessctl set -d kbd_backlight -- +5%";
          "${win}+F1" = "exec brightnessctl set -d kbd_backlight -- -5%";

          # Media control
          "--locked XF86AudioPlay" = "exec playerctl --player playerctld play-pause";
          "--locked XF86AudioNext" = "exec playerctl --player playerctld next";
          "--locked XF86AudioPrev" = "exec playerctl --player playerctld previous";
          "--locked ${hyper}+Up" = "exec playerctl --player playerctld play-pause";
          "--locked ${hyper}+Down" = "exec playerctl --player playerctld play-pause";
          "--locked ${hyper}+Left" = "exec playerctl --player playerctld previous";
          "--locked ${hyper}+Right" = "exec playerctl --player playerctld next";

          "--locked XF86AudioMute" = "exec audio output-mute";
          "--locked XF86AudioRaiseVolume" = "exec audio output-volume-up";
          "--locked XF86AudioLowerVolume" = "exec audio output-volume-down";
          "--locked ${win}+Up" = "exec audio output-mute";
          "--locked ${win}+Down" = "exec audio output-mute";
          "--locked ${win}+Right" = "exec audio output-volume-up";
          "--locked ${win}+Left" = "exec audio output-volume-down";
          "--locked ${win}+Shift+Up" = "exec audio input-mute";
          "--locked ${win}+Shift+Down" = "exec audio input-mute";
          "--locked ${win}+Shift+Right" = "exec audio input-volume-up";
          "--locked ${win}+Shift+Left" = "exec audio input-volume-down";

          # Reload the configuration file
          "${win}+r" = "reload";

          # Jump between windows
          "${hyper}+Tab" = "exec swayr switch-to-urgent-or-lru-window";

          # Switch to workspace using number row
          "${hyper}+1" = "${workspace1}";
          "${hyper}+2" = "${workspace2}";
          "${hyper}+3" = "${workspace3}";
          "${hyper}+4" = "${workspace4}";
          "${hyper}+5" = "${workspace5}";
          "${hyper}+6" = "${workspace6}";
          "${hyper}+7" = "${workspace7}";
          "${hyper}+8" = "${workspace8}";
          "${hyper}+9" = "${workspace9}";
          "${hyper}+0" = "${workspace10}";

          # Switch to workspace using keypad
          "${hyper}+KP_1" = "${workspace1}";
          "${hyper}+KP_2" = "${workspace2}";
          "${hyper}+KP_3" = "${workspace3}";
          "${hyper}+KP_4" = "${workspace4}";
          "${hyper}+KP_5" = "${workspace5}";
          "${hyper}+KP_6" = "${workspace6}";
          "${hyper}+KP_7" = "${workspace7}";
          "${hyper}+KP_8" = "${workspace8}";
          "${hyper}+KP_9" = "${workspace9}";
          "${hyper}+KP_0" = "${workspace10}";

          # Move window to workspace using number row
          "${win}+1" = "move container to ${workspace1}";
          "${win}+2" = "move container to ${workspace2}";
          "${win}+3" = "move container to ${workspace3}";
          "${win}+4" = "move container to ${workspace4}";
          "${win}+5" = "move container to ${workspace5}";
          "${win}+6" = "move container to ${workspace6}";
          "${win}+7" = "move container to ${workspace7}";
          "${win}+8" = "move container to ${workspace8}";
          "${win}+9" = "move container to ${workspace9}";
          "${win}+0" = "move container to ${workspace10}";

          # Move window to workspace using keypad
          "${win}+KP_1" = "move container to ${workspace1}";
          "${win}+KP_2" = "move container to ${workspace2}";
          "${win}+KP_3" = "move container to ${workspace3}";
          "${win}+KP_4" = "move container to ${workspace4}";
          "${win}+KP_5" = "move container to ${workspace5}";
          "${win}+KP_6" = "move container to ${workspace6}";
          "${win}+KP_7" = "move container to ${workspace7}";
          "${win}+KP_8" = "move container to ${workspace8}";
          "${win}+KP_9" = "move container to ${workspace9}";
          "${win}+KP_0" = "move container to ${workspace10}";

          # Modes
          "${win}+a" = "mode $mode_audio";
          "${hyper}+r" = "mode $mode_resize";
          "${win}+e" = "mode $mode_system";
          "${win}+m" = "mode $mode_workspaces_monitors";
        };

        startup = [
          {
            command = "cggrep aerc || cglaunch --term aerc";
            always = true;
          }
          {
            command = "cggrep signal-desktop || cglaunch signal-desktop --js-flags=--no-decommit-pooled-pages";
            always = true;
          }
          {
            command = "cggrep thunderbird || cglaunch thunderbird";
            always = true;
          }
        ];
      };
    };
}
