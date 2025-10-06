self@{ config, pkgs, boot, hostname, sensitive, modulesPath, lib, ... }:
{
  programs.tmux = {
    enable = true;
    plugins = [
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

      # tmux now opens splits in the current directory
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
    '';
  };
}
