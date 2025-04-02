{ config, pkgs, sensitive, ... }:
{
  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ./sddm-astronaut.nix {
      theme = "hyprland_kath";
      # theme = "pixel_sakura";
      themeConfig = {
        General = {
          # HeaderText = "Hi";
          Background = "${sensitive.crusader.login-background-animated}";
          # FontSize = "10.0";
          HaveFormBackground = "false";
          HideSystemButtons = "false";
        };
      };
    })
  ];
  services.displayManager.sddm = {
    wayland.enable = true;
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
    ];
  };

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
}
