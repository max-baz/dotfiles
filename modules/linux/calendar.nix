{ config, ... }: {
  home-manager.users.${config.user} = {
    programs.thunderbird = {
      enable = true;

      profiles."default".isDefault = true;

      settings = {
        "app.update.auto" = false;
        "calendar.alarms.eventalarmlen" = 0;
        "calendar.alarms.onforevents" = 1;
        "calendar.alarms.onfortodos" = 1;
        "calendar.alarms.playsound" = false;
        "calendar.alarms.todoalarmlen" = 0;
        "calendar.event.defaultlength" = 30;
        "calendar.events.defaultActionEdit" = true;
        "calendar.item.editInTab" = true;
        "calendar.task.defaultdueoffset" = 0;
        "calendar.task.defaultdue" = "offsetcurrent";
        "calendar.timezone.local" = "Europe/Copenhagen";
        "calendar.timezone.useSystemTimezone" = true;
        "calendar.view.visiblehours" = 14;
        "mail.biff.play_sound" = false;
        "mail.biff.show_alert" = false;
        "mailnews.start_page.enabled" = false;
        "mail.shell.checkDefaultClient" = false;
        "privacy.donottrackheader.enabled" = true;
      };
    };
  };
}
