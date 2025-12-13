{
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc)

          (deftemplate charmod (char mod)
            (switch
              ((key-timing 2 less-than 250)) $char break
              () (tap-hold-release 200 500 $char $mod) break
            )
          )

          (deflayermap (main)
            lmeta (multi lmeta lalt)
            caps (t! charmod esc lctl)
            spc (t! charmod spc lmet)
          )
        '';
      };
    };
  };
}
