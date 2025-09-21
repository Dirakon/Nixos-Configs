self@{ config, pkgs, boot, kanata-layout-syncer, hyprland-vim-kbswitch, ... }:
{
  environment.systemPackages = [
    kanata-layout-syncer
    hyprland-vim-kbswitch
    (pkgs.writeShellScriptBin "switch-layout-with-kanata" ''
      # Get the current layout and trim any surrounding whitespace
      output=$(hyprlandkbswitcher --get 2>/dev/null)
      exit_code=$?
      trimmed_output=$(echo "$output" | xargs)

      if [ $exit_code -ne 0 ] || [ "$trimmed_output" = "ru" ]; then
          kanata-layout-syncer --layer base
          hyprlandkbswitcher --set us
      elif [ "$trimmed_output" = "us" ]; then
          kanata-layout-syncer --layer ru-diktor
          hyprlandkbswitcher --set ru
      fi
    '')

  ];

  services.kanata = {
    enable = true;

    keyboards = {

      main = {
        port = 38234;
        devices = [ ];
        config = ''
          (defsrc
            lctl rctl lsft rsft lalt ralt lmet rmet
            caps
            ;; Add all your other keys here
            q w f p b j l u y ' a r s t g m n e i o z x c d v k h , . /
          )

          (defvar
            mods (lctl rctl lsft rsft lalt ralt lmet rmet)
          )

          ;; Base layer (Colemak)
          (deflayer base
            lctl rctl lsft rsft lalt ralt lmet rmet
            lctl
            q w f p b j l u y ' a r s t g m n e i o z x c d v k h , . /
          )

          ;; Russian Diktor layer (only active when Russian layout is selected)
          (deflayer ru-diktor
            lctl rctl lsft rsft lalt ralt lmet rmet
            lctl

            (fork w q $mods)

            ;; ьъ
            (fork (tap-dance 200 (m ])) w $mods)

            (fork z f $mods)
            (fork g p $mods)
            (fork u b $mods)
            (fork p j $mods)
            (fork d l $mods)
            (fork r u $mods)
            (fork l y $mods)
            (fork x ' $mods)

            ;; todo: шщ tap dance

            (fork e a $mods)
            (fork b r $mods)
            (fork t s $mods)
            (fork j t $mods)
            (fork f g $mods)
            (fork k m $mods)
            (fork y n $mods)
            (fork n e $mods)
            (fork c i $mods)
            (fork h o $mods)

            (fork a z $mods)
            (fork ' x $mods)
            (fork [ c $mods)
            (fork s d $mods)
            (fork . v $mods)
            (fork , k $mods)
            (fork v h $mods)
            (fork q , $mods)
            (fork / . $mods)
            (fork ; / $mods)
          )
        '';
      };
    };
  };
}
