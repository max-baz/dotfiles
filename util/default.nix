{
  systemdService = { Description, ExecStart, Environment ? [ ] }: {
    Unit = {
      Description = Description;
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Environment = Environment;
      ExecStart = ExecStart;
      Restart = "on-failure";
      RestartSec = 10;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  makeEmailAccount = { passCmd, address, imapHost, notifyCmd, smtpHost ? "", smtpPort ? 465, userName ? address, primary ? false, aercExtraAccounts ? { }, aercExtraBinds ? { } }:
    let
      realName = "Max Baz";
      pgp-key-id = "56C3E775E72B0C8B1C0C1BD0B5DB77409B11B601";
    in
    {
      realName = realName;
      address = address;
      userName = userName;
      passwordCommand = passCmd;
      imap.host = imapHost;
      smtp =
        if smtpHost != "" then {
          host = smtpHost;
          port = smtpPort;
          tls.enable = true;
          tls.useStartTls = false;
        } else null;
      msmtp.enable = smtpHost != "";
      imapnotify = {
        enable = true;
        onNotify = notifyCmd;
        boxes = [ "INBOX" ];
      };
      aerc = {
        enable = true;
        extraBinds = aercExtraBinds;
        extraAccounts = {
          pgp-self-encrypt = true;
          pgp-key-id = pgp-key-id;
          signature-cmd = "echo 'Max'";
          folders-sort = "INBOX";
        } // aercExtraAccounts;
      };
      notmuch.enable = true;
      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        remove = "both";
        extraConfig.channel = {
          CopyArrivalDate = "yes";
        };
      };
      folders.inbox = "INBOX";
      signature = {
        text = realName;
        showSignature = "append";
      };
      primary = primary;
    };
}
