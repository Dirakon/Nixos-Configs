{ pkgs
, unstable
, config
, lib
, sensitive
, my-utils
, ...
}:
{
  environment.systemPackages = [
    unstable.yt-dlp
  ];

  home-manager.users.dirakon = {

    programs.mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        memo # [h]istory
        mpris # playerctl integration
        autoload # all files in current directory are added to playlist
        uosc # some kinda UI overhaul?
        mpv-cheatsheet # '?' to see keybinds
        thumbfast # thing to display thumbnails when scrolling through timeline
      ];
      config = {
        save-position-on-quit = true; # somewhat better history -- remember position too
        screenshot-directory = "/home/dirakon/Pictures/Screenshots/mpv";
        ytdl = "yes";
        ytdl-raw-options = "proxy=[http://127.0.0.1:20808],cookies-from-browser=firefox,retry-sleep=5,retries=infinite,ignore-errors=";
        force-window = true;
        cache = "yes";
        cache-secs = 3000;

        ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
      };

      bindings = {
        "a" = "add volume -5";
        "d" = "add volume 5";
        "s" = "add volume -25";
        "w" = "add volume 25";
        "0" = "seek 0  absolute-percent";
        "1" = "seek 10 absolute-percent";
        "2" = "seek 20 absolute-percent";
        "3" = "seek 30 absolute-percent";
        "4" = "seek 40 absolute-percent";
        "5" = "seek 50 absolute-percent ";
        "6" = "seek 60 absolute-percent ";
        "7" = "seek 70 absolute-percent ";
        "8" = "seek 80 absolute-percent ";
        "9" = "seek 90 absolute-percent ";
      };
    };
  };
}
