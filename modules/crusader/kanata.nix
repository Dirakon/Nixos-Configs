self@{ config, pkgs, boot, ... }:
{
  services.kanata = {
    enable = true;

    keyboards = {

      main = {
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
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
