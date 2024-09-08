-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  {
    "catppuccin",
    optional = true,
    opts = {
      flavour = "mocha",
    },
  },
  { -- override nvim-cmp plugin
    "hrsh7th/nvim-cmp",
    -- override the options table that is used in the `require("cmp").setup()` call
    opts = function(_, opts)
      -- opts parameter is the default options table
      -- the function is lazy loaded so cmp is able to be required
      local cmp = require "cmp"
      -- modify the mapping part of the table
      opts.mapping["<C-i>"] = cmp.mapping {
        i = function()
          if cmp.visible() then
            cmp.abort()
          else
            cmp.complete()
          end
        end,
      }
    end,
  },
  {
    "archilkarchava/supermaven-nvim",
    -- event = "User AstroFile",
    event = "VeryLazy",
    opts = {
      keymaps = {
        accept_suggestion = "<C-f>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-x>",
      },
      -- ignore_filetypes = { cpp = true },
      -- color = {
      --   suggestion_color = "#ffffff",
      --   cterm = 244,
      -- },
      disable_inline_completion = false, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
    },
  },
  {
    "chrisgrieser/nvim-various-textobjs",
    cond = true,
    keys = {
      -- exception: indentation textobj requires two parameters, the first for
      -- exclusion of the starting border, the second for the exclusion of ending
      -- border
      {
        "ii",
        '<Cmd>lua require("various-textobjs").indentation("inner", "inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside indent",
      },
      {
        "iI",
        '<Cmd>lua require("various-textobjs").indentation("inner", "inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside indent",
      },
      {
        "ai",
        '<Cmd>lua require("various-textobjs").indentation("outer", "inner")<CR>',
        mode = { "o", "x" },
        desc = "around indent",
      },
      {
        "aI",
        '<Cmd>lua require("various-textobjs").indentation("outer", "outer")<CR>',
        mode = { "o", "x" },
        desc = "Around indent",
      },
      {
        "ie",
        '<Cmd>lua require("various-textobjs").entireBuffer()<CR>',
        mode = { "o", "x" },
        desc = "Entire buffer",
      },
      {
        "ae",
        '<Cmd>lua require("various-textobjs").entireBuffer()<CR>',
        mode = { "o", "x" },
        desc = "Entire buffer",
      },
      {
        "<Leader>r",
        '<Cmd>lua require("various-textobjs").restOfParagraph()<CR>',
        mode = { "o", "x" },
        desc = "Rest of paragraph",
      },
      {
        "R",
        '<Cmd>lua require("various-textobjs").restOfIndentation()<CR>',
        mode = { "o", "x" },
        desc = "Rest of indentation",
      },
      {
        "|",
        '<Cmd>lua require("various-textobjs").column()<CR>',
        mode = { "o", "x" },
        desc = "Column",
      },
      {
        "ik",
        '<Cmd>lua require("various-textobjs").key("inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside key",
      },
      {
        "ak",
        '<Cmd>lua require("various-textobjs").key("outer")<CR>',
        mode = { "o", "x" },
        desc = "Around key",
      },
      {
        "iv",
        '<Cmd>lua require("various-textobjs").value("inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside value",
      },
      {
        "av",
        '<Cmd>lua require("various-textobjs").value("outer")<CR>',
        mode = { "o", "x" },
        desc = "Around value",
      },
      {
        "im",
        '<Cmd>lua require("various-textobjs").chainMember("inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside chain member",
      },
      {
        "am",
        '<Cmd>lua require("various-textobjs").chainMember("outer")<CR>',
        mode = { "o", "x" },
        desc = "Around chain member",
      },
      {
        "i<Leader>w",
        '<Cmd>lua require("various-textobjs").subword("inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside subword",
      },
      {
        "a<Leader>w",
        '<Cmd>lua require("various-textobjs").subword("outer")<CR>',
        mode = { "o", "x" },
        desc = "Around subword",
      },
    },
  },
  {
    "folke/flash.nvim",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            x = {
              ["R"] = false,
            },
            o = {
              ["R"] = false,
            },
          },
        },
      },
    },
    opts = {
      -- highlight = {
      --   backdrop = false,
      -- },
      -- jump = {
      --   autojump = true,
      -- },
      modes = {
        search = {
          enabled = false,
        },
        char = {
          enabled = true,
          -- highlight = { backdrop = false },
        },
      },
    },
    keys = function(_, keys)
      local function wrapped_flash()
        if vim.g.vscode then vim.cmd "normal! zz" end
        return require "flash"
      end
      local mappings = {
        {
          "s",
          mode = { "n", "o", "x" },
          function()
            wrapped_flash().jump {
              jump = {
                inclusive = false,
              },
            }
          end,
          desc = "Flash",
        },
        {
          "s<Enter>",
          mode = { "n", "o", "x" },
          function()
            wrapped_flash().jump {
              continue = true,
            }
          end,
          desc = "Flash continue last search",
        },
      }

      if not vim.g.vscode then
        vim.list_extend(mappings, {
          {
            "r",
            mode = "o",
            function() require("flash").remote() end,
            desc = "Remote Flash",
          },
          {
            "S",
            mode = { "n", "x", "o" },
            function() require("flash").treesitter() end,
            desc = "Flash treesitter",
          },
        })
      end

      return vim.list_extend(keys, mappings)
    end,
    config = function(_, opts)
      local function set_highlights()
        vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = "gray" })
        if vim.g.vscode then
          vim.api.nvim_set_hl(0, "FlashLabel", {
            fg = "#ff0000",
            bold = true,
            nocombine = true,
          })
          vim.api.nvim_set_hl(0, "FlashMatch", { fg = "NONE", bg = "#613315" })
        end
      end
      vim.api.nvim_create_autocmd({ "ColorScheme" }, {
        callback = set_highlights,
      })
      set_highlights()
      require("flash").setup(opts)
    end,
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require "mini.ai"
      local custom_textobjects = {
        -- Tweak argument textobject
        -- a = require("mini.ai").gen_spec.argument({ brackets = { "%b()" } }),
        t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        b = { "%b()", "^.%s*().-()%s*.$" },
        B = { "%b{}", "^.%s*().-()%s*.$" },
        r = { "%b[]", "^.%s*().-()%s*.$" },
        -- Now `vax` should select `xxx` and `vix` - middle `x`
        -- x = { "x()x()x" },
      }
      local spec_treesitter = ai.gen_spec.treesitter
      custom_textobjects.o = spec_treesitter {
        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
      }
      custom_textobjects.f = spec_treesitter { a = "@function.outer", i = "@function.inner" }
      custom_textobjects.a = spec_treesitter { a = "@parameter.outer", i = "@parameter.inner" }
      custom_textobjects.c = spec_treesitter { a = "@class.outer", i = "@class.inner" }
      return {
        n_lines = 500,
        custom_textobjects = custom_textobjects,
        silent = true,
      }
    end,
  },
  {
    "echasnovski/mini.bracketed",
    keys = {
      {
        "<M-O>",
        function() pcall(require("mini.bracketed").jump, "backward", { wrap = false }) end,
        mode = "n",
      },
      {
        "<M-I>",
        function() pcall(require("mini.bracketed").jump, "forward", { wrap = false }) end,
        mode = "n",
      },
    },
    opts = {
      -- First-level elements are tables describing behavior of a target:
      --
      -- - <suffix> - single character suffix. Used after `[` / `]` in mappings.
      --   For example, with `b` creates `[B`, `[b`, `]b`, `]B` mappings.
      --   Supply empty string `''` to not create mappings.
      --
      -- - <options> - table overriding target options.
      --
      -- See `:h mini_bracketed.config` for more info.

      buffer = { suffix = vim.g.vscode and "" or "b", options = {} },
      comment = { suffix = "/", options = {} },
      conflict = { suffix = vim.g.vscode and "" or "x", options = {} },
      diagnostic = { suffix = vim.g.vscode and "" or "d", options = {} },
      file = { suffix = vim.g.vscode and "" or "f", options = {} },
      indent = { suffix = "i", options = {} },
      jump = { suffix = "j", options = {} },
      location = { suffix = "l", options = {} },
      oldfile = { suffix = vim.g.vscode and "" or "o", options = {} },
      quickfix = { suffix = vim.g.vscode and "" or "q", options = {} },
      treesitter = { suffix = "t", options = {} },
      undo = { suffix = "", options = {} },
      window = { suffix = vim.g.vscode and "" or "w", options = {} },
      yank = { suffix = "y", options = {} },
    },
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = ":AvanteBuild",
    opts = {
      ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
      provider = "copilot", -- Recommend using Claude
    },
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          local prefix = "<Leader>a"

          maps.n[prefix] = { desc = "Avante" }
        end,
      },
      --- The below dependencies are optional,
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
    },
    specs = {
      { -- if copilot.lua is available, default to copilot provider
        "zbirenbaum/copilot.lua",
        optional = true,
        specs = {
          {
            "yetone/avante.nvim",
            opts = {
              provider = "copilot",
            },
          },
        },
      },
      {
        -- make sure `Avante` is added as a filetype
        "MeanderingProgrammer/render-markdown.nvim",
        optional = true,
        opts = function(_, opts)
          if not opts.file_types then opts.filetypes = { "markdown" } end
          opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "Avante" })
        end,
      },
      {
        -- make sure `Avante` is added as a filetype
        "OXY2DEV/markview.nvim",
        optional = true,
        opts = function(_, opts)
          if not opts.filetypes then opts.filetypes = { "markdown", "quarto", "rmd" } end
          opts.filetypes = require("astrocore").list_insert_unique(opts.filetypes, { "Avante" })
        end,
      },
    },
  },
  {
    "nanotee/zoxide.vim",
    cmd = {
      "Z",
      "Lz",
      "Tz",
      "Zi",
      "Lzi",
      "Tzi",
    },
  },
  {
    "jedrzejboczar/exrc.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {},
  },
  {
    "gbprod/substitute.nvim",
    vscode = true,
    version = "*",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["gr"] = { function() require("substitute").operator() end, desc = "Substitute" },
              ["gra"] = {
                function()
                  require("substitute").operator {
                    motion = "a",
                  }
                end,
                desc = "Substitute",
              },
              ["grr"] = { function() require("substitute").line() end, desc = "Substitute line" },
            },
            x = {
              ["gR"] = { function() require("substitute").visual() end, desc = "Substitute" },
            },
          },
        },
      },
    },
    opts = {
      highlight_substituted_text = {
        enabled = true,
        timer = 175,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      {
        "nvim-neotest/neotest-jest",
        optional = true,
        opts = {
          cwd = function(file)
            local lib = require "neotest.lib"
            local rootPath = lib.files.match_root_pattern "package.json"(file)
            if rootPath then return rootPath end
            return vim.fn.getcwd()
          end,
          jest_test_discovery = false,
        },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      {
        "marilari88/neotest-vitest",
      },
    },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-vitest" { vitestCommand = "bunx vitest" })
    end,
  },
  {
    "mbbill/undotree",
    optional = true,
    dependencies = {
      "AstroNvim/astrocore",
      ---@type AstroCoreOpts
      opts = {
        mappings = {
          n = {
            ["<Leader>U"] = {
              "<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>",
              desc = "Toggle undo tree",
            },
          },
        },
      },
    },
  },
  {
    "f-person/git-blame.nvim",
    optional = true,
    opts = {
      enabled = false,
    },
  },
  {
    "pwntester/octo.nvim",
    optional = true,
    opts = {
      suppress_missing_scope = {
        projects_v2 = true,
      },
    },
  },
  {
    "stevearc/oil.nvim",
    optional = true,
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<M-e>"] = { function() require("oil").toggle_float() end, desc = "Open folder in Oil" },
            },
          },
        },
      },
    },
  },

  -- -- == Examples of Adding Plugins ==
  --
  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function() require("lsp_signature").setup() end,
  -- },
  --
  -- -- == Examples of Overriding Plugins ==
  --
  -- -- customize alpha options
  -- {
  --   "goolord/alpha-nvim",
  --   opts = function(_, opts)
  --     -- customize the dashboard header
  --     opts.section.header.val = {
  --       " █████  ███████ ████████ ██████   ██████",
  --       "██   ██ ██         ██    ██   ██ ██    ██",
  --       "███████ ███████    ██    ██████  ██    ██",
  --       "██   ██      ██    ██    ██   ██ ██    ██",
  --       "██   ██ ███████    ██    ██   ██  ██████",
  --       " ",
  --       "    ███    ██ ██    ██ ██ ███    ███",
  --       "    ████   ██ ██    ██ ██ ████  ████",
  --       "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
  --       "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
  --       "    ██   ████   ████   ██ ██      ██",
  --     }
  --     return opts
  --   end,
  -- },
  --
  -- -- You can disable default plugins as follows:
  -- { "max397574/better-escape.nvim", enabled = false },
  --
  -- -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  -- {
  --   "L3MON4D3/LuaSnip",
  --   config = function(plugin, opts)
  --     require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
  --     -- add more custom luasnip configuration such as filetype extend or custom snippets
  --     local luasnip = require "luasnip"
  --     luasnip.filetype_extend("javascript", { "javascriptreact" })
  --   end,
  -- },
  --
  -- {
  --   "windwp/nvim-autopairs",
  --   config = function(plugin, opts)
  --     require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
  --     -- add more custom autopairs configuration such as custom rules
  --     local npairs = require "nvim-autopairs"
  --     local Rule = require "nvim-autopairs.rule"
  --     local cond = require "nvim-autopairs.conds"
  --     npairs.add_rules(
  --       {
  --         Rule("$", "$", { "tex", "latex" })
  --           -- don't add a pair if the next character is %
  --           :with_pair(cond.not_after_regex "%%")
  --           -- don't add a pair if  the previous character is xxx
  --           :with_pair(
  --             cond.not_before_regex("xxx", 3)
  --           )
  --           -- don't move right when repeat character
  --           :with_move(cond.none())
  --           -- don't delete if the next character is xx
  --           :with_del(cond.not_after_regex "xx")
  --           -- disable adding a newline when you press <cr>
  --           :with_cr(cond.none()),
  --       },
  --       -- disable for .vim files, but it work for another filetypes
  --       Rule("a", "a", "-vim")
  --     )
  --   end,
  -- },
}
