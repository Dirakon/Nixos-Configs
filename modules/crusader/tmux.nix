self@{ config, pkgs, boot, hostname, sensitive, modulesPath, lib, ... }:
{
  programs.tmux = {
    enable = true;
    plugins = [
      # A thing to navigate through tmux like in nvim (ctrl+[hjkl])
      # (needs analogous plugin in nvim)
      pkgs.tmuxPlugins.vim-tmux-navigator
    ];
    extraConfig = ''
      # for better selection mode
      set -g mouse on
      setw -g mode-keys vi
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      # recomended setup for good nvim (see nvim :checkhealth)
      set-option -sg escape-time 10
      set-option -g focus-events on
      set-option -g default-terminal "screen-256color"
      set-option -a terminal-features 'alacritty:RGB'

      # ctrl-W as prefix key
      unbind C-b
      set-option -g prefix C-w
      bind-key C-w send-prefix

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
    '';
  };
}
