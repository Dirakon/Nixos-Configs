self@{ config, pkgs, boot, hostname, sensitive, modulesPath, lib, ... }:
{
  programs.tmux = {
    enable = true;
    plugins = [
      # A thing to navigate through tmux like in nvim (ctrl+[hjkl])
      # (needs analogous plugin in nvim)
      # pkgs.tmuxPlugins.vim-tmux-navigator
      # ^ cannot use because by nvim bin is called 'dev', which is unsupported by plugin above
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

      # inline of vim-tmux-navigator
      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|dev|fzf)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
    '';
  };
}
