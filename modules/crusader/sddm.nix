{ config, pkgs, sensitive, ... }:
let
  sddmBackgroundPath = pkgs.stdenv.mkDerivation {
    name = "sddm-wallpaper";
    # Using static system file instead of placing relatively to config to not push images to repo
    src = sensitive.crusader.login-background;
    buildCommand = ''
      mkdir -p $out
      cp $src $out/sddm.jpg
      ls $out
    '';
  };
in
let
  sddmTheme = pkgs.stdenv.mkDerivation {
    name = "sddm-theme";

    src = pkgs.fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-chili";
      rev = "6516d50176c3b34df29003726ef9708813d06271";
      sha256 = "036fxsa7m8ymmp3p40z671z163y6fcsa9a641lrxdrw225ssq5f3";
    };
    buildInputs = [
      sddmBackgroundPath
    ];

    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
      rm $out/assets/background.jpg
      echo $sddmBackgroundPath
      cp $buildInputs/sddm.jpg $out/assets/background.jpg
    '';
  };
in
{
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.theme = "${sddmTheme}";

  # Define the script /etc/scripts/sddm-avatar.sh
  environment.etc = {
    "scripts/sddm-avatar.sh" = {
      text = ''
        #!/run/current-system/sw/bin/bash
        for user in /home/*; do
          username=$(basename $user)
          if [ ! -f /etc/nixos/sddm/$username ]; then
            cp $user/.face.icon /var/lib/AccountsService/icons/$username
          else
            if [ $user/.face.icon -nt /var/lib/AccountsService/icons/$username ]; then
              cp -i $user/.face.icon /var/lib/AccountsService/icons/$username
            fi
          fi
        done
      '';
      mode = "0554";
    };
  };

  # Define systemd service to run script on boot
  systemd.services.sddm-avatar = {
    description = "Script to copy or update users Avatars at startup.";
    wantedBy = [ "multi-user.target" ];
    before = [ "sddm.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "/etc/scripts/sddm-avatar.sh";
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
  };

  # Ensures SDDM starts after the service.
  systemd.services.sddm = {
    after = [ "sddm-avatar.service" ];
  };

  environment.systemPackages = with pkgs; [
    # kde components for sddm theme and such
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
  ];

}
