self@{ config, pkgs, boot, kanata-layout-syncer, ... }:
{
  environment.systemPackages = [
    kanata-layout-syncer
  ];

  services.kanata = {
    enable = true;

    keyboards = {

      main = {
        port = 38234;
        # todo: second keyboard
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
        # todo: colemak-diktor config
        config = ''
          (defsrc
            caps
          )
          
          (defalias
            onlyctrl lctl
          )
          
          (deflayer base
            @onlyctrl
          )
        '';
      };
    };
  };
}
