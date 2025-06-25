self@{ config, pkgs, boot, hostname, sensitive, modulesPath, lib, ... }:
let
  navigatorScript = pkgs.writeShellScriptBin "navigator.sh" ''
    set -e

    cmd="$(tmux display -p '#{pane_current_command}')"
    cmd="$(basename "$cmd" | tr A-Z a-z)"
    pane_count="$(tmux list-panes | wc -l)"
    # echo $cmd

    if [ "''${cmd%m}" = "vi" ] || [ "''${cmd%m}" = "dev" ] || [ "''${cmd%m}" = "nvi" ] || [ "$pane_count" -eq 1 ]; then
      direction="$(echo "''${1#-}" | tr 'lLDUR' '\\hjkl')"
      tmux send-keys "C-$direction"
      # echo "send C-$direction"
    else
      tmux select-pane "$@"
      # echo "not send"
    fi
  '';
in
{
  programs.tmux = {
    enable = true;
    plugins = [
      # A thing to navigate through tmux like in nvim (ctrl+[hjkl])
      # (needs analogous plugin in nvim)
      # pkgs.tmuxPlugins.vim-tmux-navigator
      # ^ cannot use because by nvim bin is called 'dev', which is unsupported by plugin above

      pkgs.tmuxPlugins.jump
      pkgs.tmuxPlugins.tmux-nova
    ];
    extraConfigBeforePlugins = ''
      set -g @nova-nerdfonts true
      set -g @nova-pane "#I #W#{?window_zoomed_flag,+, }"
    '';
    extraConfig = ''
      # bar on bottom (for now)
      set-option -g status-position bottom

      # more scrollback
      set -g history-limit 20000

      # for better selection mode
      set -g mouse on
      setw -g mode-keys vi
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      # recommended setup for good nvim (see nvim :checkhealth)
      set-option -sg escape-time 10
      set-option -g focus-events on
      set-option -g default-terminal "tmux-256color"
      set-option -a terminal-features 'alacritty:RGB'
      set-option -ga terminal-features ",alacritty:usstyle"

      # ctrl-s as prefix key
      unbind C-b
      set-option -g prefix C-s
      bind-key C-s send-prefix

      # so that ctrl-enter does not break (wtf tmux)
      # TODO
      # set -s extended-keys on (???)

      # vim-like pane resizing  
      bind -r C-k resize-pane -U
      bind -r C-j resize-pane -D
      bind -r C-h resize-pane -L
      bind -r C-l resize-pane -R

      # and now unbind keys
      unbind Up     
      unbind Down   
      unbind Left   
      unbind Right  
      unbind C-Up   
      unbind C-Down 
      unbind C-Left 
      unbind C-Right

      # tmux now opens splits in the current directory
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      # Smart pane switching with awareness of Vim splits.
      bind-key -n 'C-k' run-shell '${navigatorScript}/bin/navigator.sh -U'
      bind-key -n 'C-j' run-shell '${navigatorScript}/bin/navigator.sh -D'
      bind-key -n 'C-h' run-shell '${navigatorScript}/bin/navigator.sh -L'
      bind-key -n 'C-l' run-shell '${navigatorScript}/bin/navigator.sh -R'
      bind-key -n "C-\\" run-shell '${navigatorScript}/bin/navigator.sh -l'

      # And it(^) continues to work in copy-mode-vi
      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
    '';
  };
}
