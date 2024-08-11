{
  description = "NixCats-based NeoVim config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    nixCats.inputs.nixpkgs.follows = "nixpkgs";

    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };

    # TODO: overlays?
    roslyn-nvim = {
      url = "github:seblj/roslyn.nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixCats, roslyn-nvim, ... }@inputs:
    let
      utils = nixCats.utils;
      luaPath = "${./.}";
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
      extra_pkg_config = {
        # allowUnfree = true;
      };

      inherit (forEachSystem (system:
        let
          # see :help nixCats.flake.outputs.overlays
          dependencyOverlays = (import ./overlays inputs) ++ [
            # This overlay grabs all the inputs named in the format
            # `plugins-<pluginName>`
            # Once we add this overlay to our nixpkgs, we are able to
            # use `pkgs.neovimPlugins`, which is a set of our plugins.
            (utils.standardPluginOverlay inputs)
            # add any flake overlays here.
          ];
          # these overlays will be wrapped with ${system}
          # and we will call the same utils.eachSystem function
          # later on to access them.
        in
        { inherit dependencyOverlays; })) dependencyOverlays;
      categoryDefinitions = { pkgs, settings, categories, name, ... }@packageDef:
        let
          mkNvimPlugin = src: pname:
            pkgs.vimUtils.buildVimPlugin {
              inherit pname src;
              version = src.lastModifiedDate;
            };
        in
        {
          # propagatedBuildInputs:
          # this section is for dependencies that should be available
          # at BUILD TIME for plugins. WILL NOT be available to PATH
          # However, they WILL be available to the shell 
          # and neovim path when using nix develop
          propagatedBuildInputs = {
            generalBuildInputs = with pkgs; [
            ];
          };

          # lspsAndRuntimeDeps:
          # this section is for dependencies that should be available
          # at RUN TIME for plugins. Will be available to PATH within neovim terminal
          # this includes LSPs
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              universal-ctags
              ripgrep
              fd
              lazygit
            ];
            neonixdev = {
              # also you can do this.
              inherit (pkgs) nix-doc nil lua-language-server nixd omnisharp-roslyn roslyn-ls;
              # nix-doc tags will make your tags much better in nix
              # but only if you have nil as well for some reason
            };
          };

          # This is for plugins that will load at startup without using packadd:
          startupPlugins = {
            debug = with pkgs.vimPlugins; [
              nvim-nio
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text
            ];
            lint = with pkgs.vimPlugins; [
              nvim-lint
            ];
            format = with pkgs.vimPlugins; [
              conform-nvim
            ];
            # yes these category names are arbitrary
            markdown = with pkgs.vimPlugins; [
              markdown-preview-nvim
            ];
            general = {
              gitPlugins = [
                # If it was included in your flake inputs as plugins-hlargs,
                # this would be how to add that plugin in your config.
                # pkgs.neovimPlugins.hlargs
              ];
              vimPlugins = {
                # you can make a subcategory
                cmp = with pkgs.vimPlugins; [
                  # cmp stuff
                  nvim-cmp
                  luasnip
                  friendly-snippets
                  cmp_luasnip
                  cmp-buffer
                  cmp-path
                  cmp-nvim-lua
                  cmp-nvim-lsp
                  cmp-cmdline
                  cmp-nvim-lsp-signature-help
                  cmp-cmdline-history
                  lspkind-nvim
                ];
                general = with pkgs.vimPlugins; [
                  neotest
                  neotest-dotnet
                  camelcasemotion
                  telescope-fzf-native-nvim
                  telescope-ui-select-nvim
                  plenary-nvim
                  telescope-nvim
                  omnisharp-extended-lsp-nvim

                  # treesitter
                  nvim-treesitter-textobjects
                  nvim-treesitter.withAllGrammars
                  nvim-lspconfig
                  (mkNvimPlugin roslyn-nvim "roslyn-nvim")
                  fidget-nvim
                  lualine-lsp-progress
                  lualine-nvim
                  gitsigns-nvim
                  which-key-nvim
                  comment-nvim
                  vim-sleuth
                  vim-fugitive
                  vim-rhubarb
                  vim-repeat
                  undotree
                  nvim-surround
                  indent-blankline-nvim
                  nvim-web-devicons
                  oil-nvim
                  lazygit-nvim
                ];
              };
            };
            # You can retreive information from the
            # packageDefinitions of the package this was packaged with.
            # :help nixCats.flake.outputs.categoryDefinitions.scheme
            themer = with pkgs.vimPlugins;
              (builtins.getAttr categories.colorscheme {
                # Theme switcher without creating a new category
                "onedark" = onedark-nvim;
                "catppuccin" = catppuccin-nvim;
                "catppuccin-mocha" = catppuccin-nvim;
                "tokyonight" = tokyonight-nvim;
                "tokyonight-day" = tokyonight-nvim;
              }
              );
            # This is obviously a fairly basic usecase for this, but still nice.
            # Checking packageDefinitions also has the bonus
            # of being able to be easily set by importing flakes.
          };

          # not loaded automatically at startup.
          # use with packadd and an autocommand in config to achieve lazy loading
          optionalPlugins = {
            neonixdev = with pkgs.vimPlugins; [
            ];
            custom = with pkgs.nixCatsBuilds; [ ];
            gitPlugins = with pkgs.neovimPlugins; [ ];
            general = with pkgs.vimPlugins; [ ];
          };

          # shared libraries to be added to LD_LIBRARY_PATH
          # variable available to nvim runtime
          sharedLibraries = {
            general = with pkgs; [
              # libgit2
            ];
          };

          # environmentVariables:
          # this section is for environmentVariables that should be available
          # at RUN TIME for plugins. Will be available to path within neovim terminal
          environmentVariables = {
            test = {
              subtest1 = {
                CATTESTVAR = "It worked!";
              };
              subtest2 = {
                CATTESTVAR3 = "It didn't work!";
              };
            };
          };

          # get the path to this python environment
          # in your lua config via
          # vim.g.python3_host_prog
          # or run from nvim terminal via :!<packagename>-python3
          extraPython3Packages = {
            test = (_: [ ]);
          };
          # populates $LUA_PATH and $LUA_CPATH
          extraLuaPackages = {
            general = [ (_: [ ]) ];
          };
        };

      packageDefinitions = {
        dev = { pkgs, ... }@misc: {
          # see :help nixCats.flake.outputs.settings
          settings = {
            # will check for config in the store rather than .config
            wrapRc = true;
            configDirName = "nixCats-nvim";
            aliases = [ ];
            # caution: this option must be the same for all packages.
            # or at least, all packages that are to be installed simultaneously.
            # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
          };
          # see :help nixCats.flake.outputs.packageDefinitions
          categories = {
            useVscodeLspOverOmnisharp = false;
            generalBuildInputs = true;
            markdown = true;
            general.vimPlugins = true;
            general.gitPlugins = true;
            custom = true;
            lint = true;
            format = true;
            neonixdev = true;
            test = {
              subtest1 = true;
            };
            debug = false;
            # you could also pass something else:
            themer = true;
            colorscheme = "catppuccin";
            theBestCat = "says meow!!";
            theWorstCat = {
              thing'1 = [ "MEOW" "HISSS" ];
              thing2 = [
                {
                  thing3 = [ "give" "treat" ];
                }
                "I LOVE KEYBOARDS"
              ];
              thing4 = "couch is for scratching";
            };
            # see :help nixCats
          };
        };
      };

      # In this section, the main thing you will need to do is change the default package name
      # to the name of the packageDefinitions entry you wish to use as the default.
      defaultPackageName = "dev";
    in

    # see :help nixCats.flake.outputs.exports
    forEachSystem
      (system:
        let
          # get our base builder
          inherit (utils) baseBuilder;
          # give it everything except packageDefinitions
          customPackager = baseBuilder luaPath
            {
              # we pass in the things to make a pkgs variable to build nvim with later
              inherit nixpkgs system dependencyOverlays extra_pkg_config;
              # and also our categoryDefinitions
            }
            categoryDefinitions;

          # and this will be our builder! it takes a name from our packageDefinitions as an argument, and builds an nvim.
          nixCatsBuilder = customPackager packageDefinitions;

          # this pkgs variable is just for using utils such as pkgs.mkShell
          # within this outputs set.
          pkgs = import nixpkgs { inherit system; };
          # The one used to build neovim is resolved inside the builder
          # and is passed to our categoryDefinitions and packageDefinitions
        in
        let nixCatsPackage = nixCatsBuilder defaultPackageName; in
        let
          idev = pkgs.writeShellScriptBin "idev" ''
            exec -a shell ${pkgs.neovide}/bin/neovide --no-fork --neovim-bin "${nixCatsPackage}/bin/${defaultPackageName}" "$@"
          '';
        in
        {
          # these outputs will be wrapped with ${system} by utils.eachSystem

          # this will make a package out of each of the packageDefinitions defined above
          # and set the default package to the one named here.
          packages = { default = nixCatsPackage; idev = idev; } // utils.mkExtraPackages nixCatsBuilder packageDefinitions;


          # choose your package for devShell
          # and add whatever else you want in it.
          devShells = {
            default = pkgs.mkShell {
              name = defaultPackageName;
              packages = [ idev ];
              inputsFrom = [ ];
              shellHook = ''
        '';
            };
          };

          # To set just packageDefinitions from the config that calls this flake.
          inherit customPackager;
        }) // {

      # now we can export some things that can be imported in other
      # flakes, WITHOUT needing to use a system variable to do it.
      # and update them into the rest of the outputs returned by the
      # eachDefaultSystem function.
      # these outputs will be NOT wrapped with ${system}

      # this will make an overlay out of each of the packageDefinitions defined above
      # and set the default overlay to the one named here.
      overlays = utils.makeOverlays luaPath
        {
          # we pass in the things to make a pkgs variable to build nvim with later
          inherit nixpkgs dependencyOverlays extra_pkg_config;
          # and also our categoryDefinitions
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      # we also export a nixos module to allow configuration from configuration.nix
      nixosModules.default = utils.mkNixosModules {
        inherit defaultPackageName dependencyOverlays luaPath
          categoryDefinitions packageDefinitions nixpkgs;
      };
      # and the same for home manager
      homeModule = utils.mkHomeModules {
        inherit defaultPackageName dependencyOverlays luaPath
          categoryDefinitions packageDefinitions nixpkgs;
      };
      inherit utils categoryDefinitions packageDefinitions;
      inherit (utils) templates baseBuilder;
      keepLuaBuilder = utils.baseBuilder luaPath;
      inherit dependencyOverlays;
      # dependencyOverlays was wrapped with the ${system} variable earlier,
      # so we export that here as well.
    };
}
