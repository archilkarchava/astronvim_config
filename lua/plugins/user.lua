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
      term_colors = true,
    },
  },
  { -- override nvim-cmp plugin
    "hrsh7th/nvim-cmp",
    optional = true,
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
      opts.sorting = opts.sorting or {}
      local compare = cmp.config.compare
      opts.sorting.comparators = {
        compare.offset,
        compare.exact,
        compare.score,
        compare.kind,
        compare.recently_used,
        compare.locality,
        compare.sort_text,
        compare.length,
        compare.order,
      }
    end,
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
    "ggandor/leap.nvim",
    dependencies = {
      "tpope/vim-repeat",
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = {
          mappings = {
            n = {
              ["s"] = { "<Plug>(leap)", desc = "Leap" },
              ["gs"] = { "<Plug>(leap-from-window)", desc = "Leap from window" },
            },
            x = {
              ["s"] = { "<Plug>(leap)", desc = "Leap" },
              ["gs"] = { "<Plug>(leap-from-window)", desc = "Leap from window" },
            },
            o = {
              ["s"] = { "<Plug>(leap)", desc = "Leap" },
              ["gs"] = { "<Plug>(leap-from-window)", desc = "Leap from window" },
            },
          },
        },
      },
    },
    specs = {
      {
        "catppuccin",
        optional = true,
        opts = { integrations = { leap = true } },
      },
    },
    opts = {},
  },
  {
    "folke/flash.nvim",
    optional = true,
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
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
  },
  {
    "echasnovski/mini.ai",
    optional = true,
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
    opts = {
      treesitter = { suffix = "", options = {} },
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
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        optional = true,
      },
      {
        "AstroNvim/astroui",
        opts = {
          icons = {
            Exrc = "",
          },
        },
      },
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          local prefix = "<Leader>E"
          maps.n[prefix] = { desc = require("astroui").get_icon("Exrc", 1, true) .. "Exrc" }
          maps.n[prefix .. "c"] = { "<cmd>ExrcCreate<cr>", desc = "Exrc create" }
          maps.n[prefix .. "e"] = { "<cmd>ExrcEdit<cr>", desc = "Exrc edit" }
          maps.n[prefix .. "E"] = { "<cmd>ExrcEditLoaded<cr>", desc = "Exrc edit loaded" }
          maps.n[prefix .. "i"] = { "<cmd>ExrcInfo<cr>", desc = "Exrc info" }
          maps.n[prefix .. "l"] = { "<cmd>ExrcLoad<cr>", desc = "Exrc load" }
          maps.n[prefix .. "L"] = { "<cmd>ExrcLoadAll<cr>", desc = "Exrc load all" }
          maps.n[prefix .. "r"] = { "<cmd>ExrcReload<cr>", desc = "Exrc reload" }
          maps.n[prefix .. "R"] = { "<cmd>ExrcReloadAll<cr>", desc = "Exrc reload all" }
          maps.n[prefix .. "u"] = { "<cmd>ExrcUnload<cr>", desc = "Exrc unload" }
          maps.n[prefix .. "U"] = { "<cmd>ExrcUnloadAll<cr>", desc = "Exrc unload all" }
        end,
      },
    },
    opts = {
      on_dir_changed = { -- Automatically load exrc files on DirChanged autocmd
        enabled = true,
        -- Wait until CursorHold and use vim.ui.select to confirm files to load, instead of loading unconditionally
        use_ui_select = false,
      },
    },
  },
  {
    "gbprod/substitute.nvim",
    vscode = true,
    version = "*",
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
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
        ---@type AstroCoreOpts
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
  {
    "sindrets/diffview.nvim",
    optional = true,
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          local prefix = "<Leader>g"
          maps.n[prefix .. "D"] = { "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" }
        end,
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
