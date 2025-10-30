{ config, pkgs, firefox-addons, ... }: {
  home-manager.users.${config.user}.programs.firefox = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.firefox-bin else pkgs.firefox;
    nativeMessagingHosts = with pkgs; [ ff2mpv-rust ];
    profiles.default = {
      userChrome = ''
        #sidebar-box[sidebarcommand^="containertabs"] #sidebar-header { display: none; }
        #navigator-toolbox[fullscreenShouldAnimate] { transition: none !important; }
        .tabbrowser-tab > .tab-stack > .tab-content[pinned][titlechanged] { background-image: none !important; }
        .tabbrowser-tab > .tab-stack > .tab-background { flex-direction: row !important; }
      '';

      extensions.packages = with firefox-addons; [
        browserpass
        clearurls
        containerise
        darkreader
        ff2mpv
        istilldontcareaboutcookies
        multi-account-containers
        privacy-badger
        refined-github
        sponsorblock
        to-google-translate
        ublock-origin
        # temporary-containers-plus
        # open-external-links-in-a-container
      ];

      settings = {
        "accessibility.force_disabled" = 1;
        "app.normandy.api_url" = "";
        "app.normandy.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "apz.gtk.kinetic_scroll.enabled" = false;
        "apz.overscroll.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.contentblocking.category" = "strict";
        "browser.ctrlTab.recentlyUsedOrder" = false;
        "browser.discovery.enabled" = false;
        "browser.download.alwaysOpenPanel" = false;
        "browser.formfill.enable" = false;
        "browser.gesture.swipe.left" = "";
        "browser.gesture.swipe.right" = "";
        "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.enabled" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.safebrowsing.downloads.remote.url" = "";
        "browser.search.suggest.enabled" = false;
        "browser.sessionstore.warnOnQuit" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.startup.page" = 3;
        "browser.tabs.inTitlebar" = 0;
        "browser.tabs.warnOnClose" = false;
        "browser.theme.dark-private-windows" = true;
        "browser.toolbars.bookmarks.visibility" = false;
        "browser.urlbar.trimURLs" = false;
        "browser.xul.error_pages.expert_bad_cert" = true;
        "cookiebanners.ui.desktop.enabled" = true;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "devtools.theme" = "auto";
        "devtools.toolbox.host" = "bottom";
        "dom.disable_window_move_resize" = true;
        "dom.forms.autocomplete.formautofill" = false;
        "dom.payments.defaults.saveAddress" = false;
        "dom.security.https_only_mode" = true;
        "dom.storage.next_gen" = true;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.available" = "off";
        "extensions.formautofill.creditCards.available" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.formautofill.heuristics.enabled" = false;
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.pocket.enabled" = false;
        "general.smoothScroll" = false;
        "gfx.webrender.all" = true;
        "layout.css.visited_links_enabled" = false;
        "media.memory_cache_max_size" = 65536;
        "network.auth.subresource-http-auth-allow" = 1;
        "network.gio.supported-protocols" = "";
        "network.http.referer.XOriginPolicy" = 2;
        "network.http.referer.XOriginTrimmingPolicy" = 2;
        "network.protocol-handler.external.mailto" = false;
        "network.proxy.socks_remote_dns" = true;
        "permissions.delegation.enabled" = false;
        "privacy.clearOnShutdown.cache" = true;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.downloads" = true;
        "privacy.clearOnShutdown.formdata" = true;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.sessions" = false;
        "privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage" = false;
        "privacy.partition.always_partition_third_party_non_cookie_storage" = true;
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
        "privacy.window.name.update.enabled" = true;
        "security.cert_pinning.enforcement_level" = 2;
        "security.mixed_content.block_display_content" = true;
        "security.OCSP.require" = true;
        "security.pki.crlite_mode" = 2;
        "security.remote_settings.crlite_filters.enabled" = true;
        "security.ssl.require_safe_negotiation" = true;
        "services.sync.engine.addons" = false;
        "services.sync.engine.creditcards" = false;
        "services.sync.engine.passwords" = false;
        "sidebar.verticalTabs" = true;
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "signon.rememberSignons" = false;
        "toolkit.coverage.endpoint.base" = "";
        "toolkit.coverage.opt-out" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "toolkit.scrollbox.smoothScroll" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "widget.non-native-theme.enabled" = true;
      };
    };
  };
}
