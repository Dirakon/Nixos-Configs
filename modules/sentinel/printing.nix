self@{ config, pkgs, boot, hostname, sensitive, ... }:
{
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.samsung-unified-linux-driver ];

  hardware.printers = {
    ensurePrinters = [
      (with sensitive.sentinel.printer; {
        name = name;
        # location = "Home";
        deviceUri = uri;
        model = model;
        ppdOptions = ppdOptions;
      })
    ];

    ensureDefaultPrinter = sensitive.sentinel.printer.name;
  };

  hardware.sane.enable = true;
  users.users.dirakon.extraGroups = [ "scanner" "lp" ];
}
