{pkgs, ...}: {
  plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "default";
          "<C-j>" = ["select_next" "fallback"];
          "<C-k>" = ["select_prev" "fallback"];
          "<C-b>" = ["scroll_documentation_up" "fallback"];
          "<C-f>" = ["scroll_documentation_down" "fallback"];
          "<C-Space>" = ["show" "fallback"];
          "<C-e>" = ["hide" "fallback"];
          "<C-CR>" = ["accept" "fallback"];
          "<S-CR>" = ["accept" "fallback"];
        };

        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "mono";
        };

        sources = {
          default = ["lsp" "path" "snippets" "buffer"];
          providers = {
            npm = {
              name = "npm";
              module = "blink-cmp-npm";
              async = true;
              score_offset = 100;
              opts = {
                ignore = [];
                only_semantic_versions = true;
                only_latest_version = false;
              };
            };
          };
        };

        snippets = {
          preset = "luasnip";
        };

        completion = {
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
            window = {
              border = "solid";
            };
          };
          menu = {
            border = "solid";
            draw = {
              columns = [
                ["kind_icon"]
                ["label" "label_description"]
                ["kind"]
              ];
            };
          };
        };
      };
    };

    luasnip = {
      enable = true;
    };
  };

  # extraPlugins = [
  #   pkgs.vimPlugins.blink-cmp-npm
  # ];
}
