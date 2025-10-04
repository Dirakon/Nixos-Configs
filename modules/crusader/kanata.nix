self@{ config
, pkgs
, lib
, boot
, kanata-layout-syncer
, hyprland-vim-kbswitch
, hypr-pkgs
, ...
}:
let
  switch-layout-with-kanata = (
    pkgs.writeShellScriptBin "switch-layout-with-kanata" ''
      # Get the current layout and trim any surrounding whitespace
      output=$(${hyprland-vim-kbswitch}/bin/hyprlandkbswitcher --get 2>/dev/null)
      exit_code=$?
      trimmed_output=$(echo "$output" | xargs)

      if [ $exit_code -ne 0 ] || [ "$trimmed_output" = "ru" ]; then
          ${kanata-layout-syncer}/bin/kanata-layout-syncer --layer base
          ${hyprland-vim-kbswitch}/bin/hyprlandkbswitcher --set us
      elif [ "$trimmed_output" = "us" ]; then
          ${kanata-layout-syncer}/bin/kanata-layout-syncer --layer ru-diktor
          ${hyprland-vim-kbswitch}/bin/hyprlandkbswitcher --set ru
      fi
    ''
  );
in
{
  environment.systemPackages = [
    kanata-layout-syncer
    hyprland-vim-kbswitch
    switch-layout-with-kanata
  ];

  systemd.user.services."change-lang-with-kanata" = {
    description = "what he said";
    path = [ hypr-pkgs.hyprland ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${switch-layout-with-kanata}/bin/switch-layout-with-kanata";
    };
    after = [ "graphical-session.target" ];
  };

  systemd.services."kanata-main" = {
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "root";
      Group = lib.mkForce "root";
    };
  };

  services.kanata = {
    enable = true;
    package = pkgs.kanata-with-cmd;

    keyboards = {

      main = {
        port = 38234;
        devices = [ ];
        extraDefCfg = "danger-enable-cmd yes";
        config = ''
          (defsrc
            lctl lsft lalt lmet
            caps
            ;; Add all your other keys here
            q w f p b j l u y ' a r s t g m n e i o z x c d v k h , . / f20 f21
          )

          (defvar
            mods (lctl lalt lmet)
          )

          ;; Base layer (Colemak)
          (deflayer base
            lctl lsft lalt lmet
            lctl
            q w f p b j l u y ' a r s t g m n e i o z x c d v k h , . / f20 (cmd ${pkgs.bashNonInteractive}/bin/bash -c "systemd-run systemctl --user -M dirakon@ start change-lang-with-kanata.service"))

          ;; Russian Diktor layer (only active when Russian layout is selected)
          (deflayer ru-diktor
            lctl lsft lalt lmet
            lctl

            (fork w q $mods)

            ;; ьъ
            (fork (tap-dance 200 (m ])) w $mods)

            (fork z f $mods)
            (fork / p $mods)
            (fork x b $mods)
            (fork p j $mods)
            (fork d l $mods)
            (fork r u $mods)
            (fork l y $mods)
            (fork q ' $mods)

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
            (fork g , $mods)
            (fork u . $mods)
            (fork ; / $mods)

            ;; щ tap dance
            (fork (tap-dance 200 (i o)) f20 $mods)

            (cmd ${pkgs.bashNonInteractive}/bin/bash -c "systemd-run systemctl --user -M dirakon@ start change-lang-with-kanata.service")
          )
        '';
      };
    };
  };
}
