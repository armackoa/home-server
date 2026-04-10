{
  inputs,
  self,
  ...
}: {
  flake.homeModules.cliTextEditors = {pkgs, ...}: {
    home.packages = with pkgs; [
      # LSPs
      lua-language-server
      pyright
      rust-analyzer
      clang-tools
      alejandra
      nil
      nix-tree
      nix-diff
      statix
      deadnix
      marksman
      python3Packages.python-lsp-server
      yamlfmt
    ];

    imports = [
      self.homeModules.helix
      self.homeModules.nvim
      # self.homeModules.emacs
      # self.homeModules.nvf
    ];
  };
  flake.homeModules.helix = {pkgs, ...}: {
    home.sessionVariables.EDITOR = "hx";

    programs.helix = {
      enable = true;
      package = pkgs.evil-helix;
      settings = {
        theme = "autumn_night_transparent";
        editor.cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      languages = {
        language-server = {
          pyright = {
            command = "${pkgs.pyright}/bin/pyright-langserver";
            args = ["--stdio"];
          };
          bash-language-server = {
            command = "${pkgs.bash-language-server}/bin/bash-language-server";
            args = ["start"];
          };
          rust-analyzer = {
            command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          };
          nil = {
            command = "${pkgs.nil}/bin/nil";
          };
          vscode-html-language-server = {
            command = "${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server";
            args = ["--stdio"];
          };
          vscode-css-language-server = {
            command = "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server";
            args = ["--stdio"];
          };
          vscode-json-language-server = {
            command = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
            args = ["--stdio"];
          };
          yaml-language-server = {
            command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
            args = ["--stdio"];
          };
          taplo = {
            command = "${pkgs.taplo}/bin/taplo";
            args = ["lsp" "stdio"];
          };
          marksman = {
            command = "${pkgs.marksman}/bin/marksman";
            args = ["server"];
          };
          clangd = {
            command = "${pkgs.clang-tools}/bin/clangd";
          };
        };

        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${pkgs.alejandra}/bin/alejandra";
            language-servers = ["nil"];
          }
          {
            name = "python";
            auto-format = true;
            language-servers = ["pyright" "ruff"];
          }
          {
            name = "bash";
            auto-format = true;
            formatter = {
              command = "${pkgs.shfmt}/bin/shfmt";
              args = ["-"];
            };
            language-servers = ["bash-language-server"];
          }
          {
            name = "rust";
            auto-format = true;
            language-servers = ["rust-analyzer"];
          }
          {
            name = "html";
            auto-format = true;
            language-servers = ["vscode-html-language-server"];
          }
          {
            name = "css";
            auto-format = true;
            language-servers = ["vscode-css-language-server"];
          }
          {
            name = "json";
            auto-format = true;
            language-servers = ["vscode-json-language-server"];
          }
          {
            name = "javascript";
            auto-format = true;
            language-servers = ["typescript-language-server"];
          }
          {
            name = "yaml";
            auto-format = true;
            language-servers = ["yaml-language-server"];
          }
          {
            name = "toml";
            auto-format = true;
            language-servers = ["taplo"];
          }
          {
            name = "markdown";
            language-servers = ["marksman"];
          }
          {
            name = "c";
            auto-format = true;
            language-servers = ["clangd"];
          }
          {
            name = "cpp";
            auto-format = true;
            language-servers = ["clangd"];
          }
        ];
      };

      themes = {
        autumn_night_transparent = {
          "inherits" = "kanagawa";
          "ui.background" = {};
        };
      };
    };
  };
  flake.homeModules.nvim = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      tree-sitter
      vimPlugins.nvim-treesitter-parsers.xml
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = false;
      viAlias = true;
      vimAlias = false;
    };

    home.activation.nvimConfig = config.lib.dag.entryAfter ["writeBoundary"] ''
      rm -rf ${config.home.homeDirectory}/.config/nvim
      ln -sf ${self.outPath}/users/user1/user1-modules/nvim ${config.home.homeDirectory}/.config/nvim
    '';
  };
  flake.homeModules.emacs = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs; [
      emacs-all-the-icons-fonts
      gnutls
      imagemagick
      zstd
    ];

    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;

      extraPackages = epkgs:
        with epkgs; [
          vterm
          pdf-tools
          tree-sitter-langs
          treesit-grammars.with-all-grammars
        ];
    };

    services.emacs = {
      enable = true;
      client.enable = true;
      package = config.programs.emacs.package;
      startWithUserSession = "graphical";
      extraOptions = ["--init-directory=${config.xdg.configHome}/emacs"];
    };

    home.sessionVariables = {
      DOOMDIR = "${config.xdg.configHome}/doom";
      EMACSDIR = "${config.xdg.configHome}/emacs";
      DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
      DOOMPROFILELOADFILE = "${config.xdg.stateHome}/doom-profiles-load.el";
    };
  };
  flake.homeModules.nvf = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [inputs.nvf.nixosModules.default];

    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          viAlias = false;
          vimAlias = true;

          theme = {
            enable = true;
            name = "everforest";
            style = "hard";
            transparent = true;
          };

          statusline.lualine.enable = true;
          telescope.enable = true;
          autocomplete.nvim-cmp.enable = true;

          enableLuaLoader = true;

          # Keybinding hints
          binds.whichKey.enable = true;

          # Toggle comment
          comments.comment-nvim.enable = true;

          # Git gutter
          git.gitsigns.enable = true;

          # Diagnostic list UI
          diagnostics.enable = true;

          # Auto-pairs and surround
          autopairs.nvim-autopairs.enable = true;
          utility.surround.enable = true;
          formatter.conform-nvim.enable = true;

          # Indent guides
          visuals.indent-blankline.enable = true;

          # Languages
          lsp.enable = true;
          lsp.trouble.enable = true;
          languages = {
            enableTreesitter = true;
            nix = {
              enable = true;
              extraDiagnostics.enable = true;
            };
            python.enable = true;
            rust.enable = true;
            clang.enable = true;
            bash.enable = true;
            css.enable = true;
            html.enable = true;
            java.enable = true;
            lua.enable = true;
            markdown.enable = true;
            sql.enable = true;
            yaml.enable = true;
          };

          keymaps = [
            {
              key = "<leader>fn";
              mode = "n";
              action = ":e %:p:h/";
            }
            {
              key = "<leader>o";
              mode = "n";
              action = "<CMD>Oil %:p:h<CR>";
            }
            # Telescope
            {
              key = "<leader>ff";
              mode = "n";
              action = "<CMD>Telescope find_files<CR>";
            }
            {
              key = "<leader>fg";
              mode = "n";
              action = "<CMD>Telescope live_grep<CR>";
            }
            {
              key = "<leader>fb";
              mode = "n";
              action = "<CMD>Telescope buffers<CR>";
            }
            {
              key = "<leader>fh";
              mode = "n";
              action = "<CMD>Telescope help_tags<CR>";
            }
            {
              key = "<C-p>";
              mode = "n";
              action = "<CMD>Telescope find_files<CR>";
            }
            # Conform
            {
              key = "<leader>mp";
              mode = "n";
              action = "<CMD>lua require('conform').format({ lsp_fallback = true, async = false, timeout_ms = 500 })<CR>";
            }
            {
              key = "<leader>mp";
              mode = "v";
              action = "<CMD>lua require('conform').format({ lsp_fallback = true, async = false, timeout_ms = 500 })<CR>";
            }
            {
              key = "<leader>ci";
              mode = "n";
              action = "<CMD>ConformInfo<CR>";
            }
          ];

          # Options
          options = {
            clipboard = "unnamedplus";

            tabstop = 4;
            shiftwidth = 4;
            expandtab = true;

            number = true;
            relativenumber = true;
          };

          # Startup
          startPlugins = with pkgs; [
            vimPlugins.nvim-tree-lua
            vimPlugins.oil-nvim
          ];
        };
      };
    };
  };
}
