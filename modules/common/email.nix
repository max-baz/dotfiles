{ config, pkgs, lib, ... }: {
  config = lib.mkIf config.personal.enable {
    home-manager.users.${config.user} = {
      programs = {
        aerc = {
          enable = true;
          templates = {
            forward_as_body = ''
              X-Mailer: aerc {{version}}

              {{- with .Signature }}
              {{.}}
              {{- end }}

              ---------- Forwarded message ---------
              From: {{.OriginalFrom | persons | join ", "}}
              Date: {{dateFormat .OriginalDate "Mon Jan 2, 2006 at 3:04 PM"}}

              {{.OriginalText}}
            '';

            quoted_reply = ''
              X-Mailer: aerc {{version}}

              {{- with .Signature }}
              {{.}}
              {{- end }}

              On {{dateFormat (.OriginalDate | toLocal) "Mon Jan 2, 2006 at 3:04 PM MST"}}, {{.OriginalFrom | names | join ", "}} wrote:
              {{ if eq .OriginalMIMEType "text/html" -}}
              {{- exec `html` .OriginalText | trimSignature | quote -}}
              {{- else -}}
              {{- trimSignature .OriginalText | quote -}}
              {{- end}}
            '';
          };
          extraConfig = {
            compose = {
              edit-headers = true;
              file-picker-cmd = "fzf --multi --query=%s";
              reply-to-self = false;
            };

            filters = ''
              .headers = ${pkgs.aerc}/libexec/aerc/filters/colorize
              text/calendar = ${pkgs.gawk}/bin/awk -f ${pkgs.aerc}/libexec/aerc/filters/calendar
              text/html = ${pkgs.aerc}/libexec/aerc/filters/html -o display_link_number=true | ${pkgs.aerc}/libexec/aerc/filters/colorize
              text/plain = ${pkgs.aerc}/libexec/aerc/filters/colorize
              text/* = ${pkgs.bat}/bin/bat -fP --file-name="$AERC_FILENAME "
              message/delivery-status = ${pkgs.aerc}/libexec/aerc/filters/colorize
              message/rfc822 = ${pkgs.aerc}/libexec/aerc/filters/colorize
              application/pdf = ${pkgs.zathura}/bin/zathura -
              application/x-sh = ${pkgs.bat}/bin/bat -fP -l sh
              audio/* = ${pkgs.mpv}/bin/mpv -
            '';

            general = {
              default-menu-cmd = "${pkgs.fzf}/bin/fzf";
              enable-osc8 = true;
              pgp-provider = "gpg";
              unsafe-accounts-conf = true;
            };

            viewer = {
              header-layout = "From|To,Cc|Bcc,Date,Subject,DKIM+|SPF+|DMARC+";
            };

            ui = {
              tab-title-account = "{{.Account}} {{if .Unread}}({{.Unread}}){{end}}";
              fuzzy-complete = true;
              mouse-enabled = true;
              msglist-scroll-offset = 5;
              show-thread-context = true;
              styleset-name = "gruvbox";
              thread-prefix-dummy = "┬";
              thread-prefix-first-child = "┬";
              thread-prefix-folded = "+";
              thread-prefix-has-siblings = "├";
              thread-prefix-indent = "";
              thread-prefix-last-sibling = "╰";
              thread-prefix-limb = "─";
              thread-prefix-lone = " ";
              thread-prefix-orphan = "┌";
              thread-prefix-stem = "│";
              thread-prefix-tip = "";
              thread-prefix-unfolded = "";
              threading-enabled = true;
              spinner = "◜,◠,◝,◞,◡,◟";
            };
          };

          extraBinds = ''
            <C-k> = :prev-tab<Enter>
            <C-j> = :next-tab<Enter>
            ? = :help keys<Enter>
            <C-c> = :prompt 'Quit?' quit<Enter>
            <C-q> = :prompt 'Quit?' quit<Enter>

            [messages]
            q = :prompt 'Quit?' quit<Enter>
            j = :next<Enter>
            k = :prev<Enter>
            <C-d> = :next 50%<Enter>
            <C-u> = :prev 50%<Enter>
            <PgDn> = :next 100%<Enter>
            <PgUp> = :prev 100%<Enter>
            g = :select 0<Enter>
            G = :select -1<Enter>
            J = :next-folder<Enter>
            K = :prev-folder<Enter>

            <Space> = :mark -t<Enter>:next<Enter>
            <Tab> = :exec checkmail<Enter>
            <Enter> = :view<Enter>
            d = :choose -o y 'Really delete this message' delete-message<Enter>
            a = :read<Enter>:archive flat<Enter>
            A = :unmark -a<Enter>:mark -T<Enter>:read<Enter>:mark -T<Enter>:archive flat<Enter>
            s = :read<Enter>:move Junk<Enter>

            m = :compose<Enter>
            r = :reply -aq<Enter>
            $ = :term<space>
            ! = :term<space>
            | = :pipe<space>

            / = :search<space>
            \ = :change-tab notmuch<Enter>:cf<Space>
            + = :query -n "{{.SubjectBase}} ({{.MessageId}})" -a notmuch thread:\{id:{{.MessageId}}\}<Enter>
            n = :next-result<Enter>
            N = :prev-result<Enter>
            <Esc> = :clear<Enter>

            v = :split<Enter>
            V = :vsplit<Enter>

            [messages:folder=Drafts]
            <Enter> = :recall<Enter>

            [view]
            / = :toggle-key-passthrough<Enter>/
            q = :close<Enter>
            o = :open<Enter>
            S = :save<space>
            | = :pipe<space>
            a = :archive flat<Enter>
            s = :move Junk<Enter>

            <C-l> = :open-link<space>

            f = :forward<Enter>
            r = :reply -aq<Enter>

            H = :toggle-headers<Enter>
            <C-p> = :prev-part<Enter>
            <C-n> = :next-part<Enter>
            J = :next<Enter>
            K = :prev<Enter>

            [view::passthrough]
            $noinherit = true
            $ex = <C-x>
            <Esc> = :toggle-key-passthrough<Enter>

            [compose]
            $noinherit = true
            $ex = <C-x>

            [compose::editor]
            $noinherit = true
            $ex = <C-x>

            [compose::review]
            y = :send<Enter> # Send
            n = :abort<Enter> # Abort (discard message, no confirmation)
            v = :preview<Enter> # Preview message
            p = :postpone<Enter> # Postpone
            q = :choose -o d discard abort -o p postpone postpone<Enter> # Abort or postpone
            e = :edit<Enter> # Edit
            a = :menu -c 'fd . --type=f | fzf -m' attach<Enter> # Add attachment
            d = :detach<space> # Remove attachment
            s = :sign<Enter> # PGP sign

            [terminal]
            $noinherit = true
            $ex = <C-x>
            <C-p> = :prev-tab<Enter>
            <C-n> = :next-tab<Enter>
          '';

          stylesets.gruvbox = ''
            # based on dracula, depends on terminal using gruvbox too
            *.default=true
            *.normal=true

            title.bg=3

            title.fg=0
            title.bold=true

            header.bold=true
            header.fg=3

            tab.selected.fg=0
            tab.selected.bg=3
            tab.selected.bold=false
            dirlist*.selected.bg=0
            dirlist*.selected.fg=white
            dirlist*.selected.bold=false
            dirlist*.selected.italic=false

            *error.bold=true
            *error.fg=red
            *warning.fg=yellow
            *success.fg=green

            statusline_error.fg=red

            msglist_unread.fg=15
            msglist_unread.bold=true
            msglist_deleted.fg=#666666
            msglist_*.selected.bg=0
            msglist_result.bg=#6272A4
            msglist_marked.fg=0
            msglist_marked.selected.fg=0
            msglist_marked.bg=3
            msglist_marked.selected.bg=3
            msglist_marked.selected.bold=true
            msglist_pill.reverse=true

            part_*.fg=15
            part_mimetype.fg=4
            part_*.selected.fg=15
            part_*.selected.bg=0
            part_filename.selected.bold=true

            completion_pill.reverse=false
            selector_focused.bold=false
            selector_focused.bg=0
            selector_focused.fg=white
            selector_chooser.bold=false
            selector_chooser.bg=0
            selector_chooser.fg=white
            default.selected.bold=false
            default.selected.fg=white
            default.selected.bg=0

            completion_default.selected.bg=0
            completion_default.selected.fg=white

            [viewer]
            *.default=true
            *.normal=true
            url.fg=4
            header.bold=true
            signature.dim=true
            diff_meta.bold=true
            diff_chunk.dim=true
            diff_add.fg=2
            diff_del.fg=1
            quote_*.fg=6
            quote_*.dim=true
            quote_1.dim=false
          '';
        };

        notmuch = {
          enable = true;
          new = {
            ignore = [
              ".uidvalidity"
              ".mbsyncstate"
              ".mbsyncstate.lock"
              ".mbsyncstate.journal"
              ".mbsyncstate.new"
            ];
            tags = [ "unread" "inbox" "new" ];
          };
        };

        msmtp.enable = true;
        mbsync.enable = true;
      };

      accounts.email = {
        maildirBasePath = ".mail";
        accounts.notmuch = {
          realName = "notmuch";
          address = "notmuch@localhost";
          aerc = {
            enable = true;
            extraAccounts.source = "notmuch://~/.mail";
            extraBinds.messages."r" = '':reply -aqA {{index (.Filename | split ("/")) 4}}<Enter>'';
            extraBinds.view."r" = '':reply -aqA {{index (.Filename | split ("/")) 4}}<Enter>'';
          };
        };
      };

      services = {
        imapnotify.enable = true;
      };

      home.packages = with pkgs; [
        aerc
        w3m
        dante
      ];
    };
  };
}

