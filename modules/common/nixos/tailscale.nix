{ config, lib, ... }: {
  services.tailscale = {
    enable = true;
  } // lib.attrsets.optionalAttrs (builtins.hasAttr "useRoutingFeatures" config.services.tailscale) {
    useRoutingFeatures = "client";
  };
}
