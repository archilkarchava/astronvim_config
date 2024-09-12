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
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      local cmp = require "cmp"
      local is_macos = vim.uv.os_uname().sysname == "Darwin"
      local toggle_cmp = cmp.mapping {
        i = function()
          if cmp.visible() then
            cmp.abort()
          else
            cmp.complete()
          end
        end,
      }
      opts.mapping["<C-i>"] = toggle_cmp
      if is_macos then opts.mapping["<D-i>"] = toggle_cmp end
    end,
  },
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          for _, mode in ipairs { "o", "x" } do
            maps[mode]["ii"] =
              { function() require("various-textobjs").indentation("inner", "inner") end, desc = "Inside indent" }
            maps[mode]["iI"] =
              { function() require("various-textobjs").indentation("inner", "inner") end, desc = "Inside indent" }
            maps[mode]["ai"] =
              { function() require("various-textobjs").indentation("outer", "inner") end, desc = "around indent" }
            maps[mode]["aI"] =
              { function() require("various-textobjs").indentation("outer", "outer") end, desc = "Around indent" }
            maps[mode]["ie"] = { function() require("various-textobjs").entireBuffer() end, desc = "Entire buffer" }
            maps[mode]["ae"] = { function() require("various-textobjs").entireBuffer() end, desc = "Entire buffer" }
            maps[mode]["<leader>R"] =
              { function() require("various-textobjs").restOfParagraph() end, desc = "Rest of paragraph" }
            maps[mode]["R"] =
              { function() require("various-textobjs").restOfIndentation() end, desc = "Rest of indentation" }
            maps[mode]["|"] = { function() require("various-textobjs").column() end, desc = "Column" }
            maps[mode]["ik"] = { function() require("various-textobjs").key "inner" end, desc = "Inside key" }
            maps[mode]["ak"] = { function() require("various-textobjs").key "outer" end, desc = "Around key" }
            maps[mode]["iv"] = { function() require("various-textobjs").value "inner" end, desc = "Inside value" }
            maps[mode]["av"] = { function() require("various-textobjs").value "outer" end, desc = "Around value" }
            maps[mode]["im"] =
              { function() require("various-textobjs").chainMember "inner" end, desc = "Inside chain member" }
            maps[mode]["am"] =
              { function() require("various-textobjs").chainMember "outer" end, desc = "Around chain member" }
            maps[mode]["i<leader>w"] =
              { function() require("various-textobjs").subword "inner" end, desc = "Inside subword" }
            maps[mode]["a<leader>w"] =
              { function() require("various-textobjs").subword "outer" end, desc = "Around subword" }
          end
        end,
      },
    },
  },
  {
    "ggandor/leap.nvim",
    dependencies = {
      "tpope/vim-repeat",
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          for _, mode in ipairs { "n", "x", "o" } do
            maps[mode]["s"] = { "<Plug>(leap)", desc = "Leap" }
            maps[mode]["gs"] = { "<Plug>(leap-from-window)", desc = "Leap from window" }
          end
        end,
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
    optional = true,
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
    },
    config = function()
      for _, value in ipairs { "Zi", "Tzi", "Lzi" } do
        vim.api.nvim_del_user_command(value)
      end
    end,
  },
  {
    "jedrzejboczar/exrc.nvim",
    lazy = false,
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        optional = true,
      },
      {
        "AstroNvim/astroui",
        opts = { icons = { Exrc = "" } },
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
      on_vim_enter = true,
      lsp = { auto_setup = false },
      on_dir_changed = { -- Automatically load exrc files on DirChanged autocmd
        enabled = true,
        -- Wait until CursorHold and use vim.ui.select to confirm files to load, instead of loading unconditionally
        use_ui_select = false,
      },
    },
  },
  {
    "gbprod/substitute.nvim",
    event = "VeryLazy",
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
    "lewis6991/gitsigns.nvim",
    optional = true,
    opts = {
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 300,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
      },
    },
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = {
          mappings = {
            n = {
              ["<leader>gB"] = { "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle inline git blame" },
            },
          },
        },
      },
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
  {
    "zeioth/garbage-day.nvim",
    optional = true,
    opts = {
      excluded_lsp_clients = {
        "null-ls",
        "jdtls",
        "marksman",
        "lua_ls",
        "copilot",
      },
    },
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = {
          mappings = {
            n = {
              ["<leader>lc"] = {
                function()
                  require("garbage-day.utils").stop_lsp()
                  require("garbage-day.utils").start_lsp()
                end,
                desc = "Garbage collect LSP clients",
              },
            },
          },
        },
      },
    },
  },
  {
    "danymat/neogen",
    dependencies = {
      { "AstroNvim/astroui", opts = { icons = { Annotation = "󰷉" } } },
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          local prefix = "<Leader>A"
          maps.n[prefix] = { desc = require("astroui").get_icon("Annotation", 1, true) .. "Annotation" }
          maps.n[prefix .. "<CR>"] = { function() require("neogen").generate { type = "any" } end, desc = "Current" }
          maps.n[prefix .. "c"] = { function() require("neogen").generate { type = "class" } end, desc = "Class" }
          maps.n[prefix .. "f"] = { function() require("neogen").generate { type = "func" } end, desc = "Function" }
          maps.n[prefix .. "t"] = { function() require("neogen").generate { type = "type" } end, desc = "Type" }
          maps.n[prefix .. "F"] = { function() require("neogen").generate { type = "file" } end, desc = "File" }
        end,
      },
    },
    cmd = "Neogen",
    opts = {
      snippet_engine = "luasnip",
      languages = {
        lua = { template = { annotation_convention = "emmylua" } },
        typescript = { template = { annotation_convention = "tsdoc" } },
        typescriptreact = { template = { annotation_convention = "tsdoc" } },
      },
    },
  },
  {
    "chrisgrieser/nvim-chainsaw",
    event = "VeryLazy",
    optional = true,
    opts = {
      logStatements = {
        variableLog = {
          javascript = {
            "/* prettier-ignore */ // %s",
            'console.log("%s %s:", %s);',
          },
        },
      },
    },
    dependencies = {
      { "AstroNvim/astroui", opts = { icons = { Chainsaw = "󰹈" } } },
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          local prefix = "<Leader>L"
          maps.n[prefix] = { desc = require("astroui").get_icon("Log", 1, true) .. "Log" }
          maps.n[prefix .. "v"] = {
            function() require("chainsaw").variableLog() end,
            desc = "Variable log",
          }
          maps.n[prefix .. "o"] = {
            function() require("chainsaw").objectLog() end,
            desc = "Object log",
          }
          maps.n[prefix .. "t"] = {
            function() require("chainsaw").typeLog() end,
            desc = "Type log",
          }
          maps.n[prefix .. "a"] = {
            function() require("chainsaw").assertLog() end,
            desc = "Assert log",
          }
          maps.n[prefix .. "b"] = {
            function() require("chainsaw").beepLog() end,
            desc = "Beep log",
          }
          maps.n[prefix .. "m"] = {
            function() require("chainsaw").messageLog() end,
            desc = "Message log",
          }
          maps.n[prefix .. "T"] = {
            function() require("chainsaw").timeLog() end,
            desc = "Time log",
          }
          maps.n[prefix .. "d"] = {
            function() require("chainsaw").debugLog() end,
            desc = "Debug log",
          }
          maps.n[prefix .. "s"] = {
            function() require("chainsaw").stacktraceLog() end,
            desc = "Stacktrace log",
          }
          maps.n[prefix .. "c"] = {
            function() require("chainsaw").clearLog() end,
            desc = "Clear log",
          }
          maps.n[prefix .. "r"] = {
            function() require("chainsaw").removeLogs() end,
            desc = "Remove all log statements created by Chainsaw",
          }
        end,
      },
    },
  },
  {
    "kkoomen/vim-doge",
    enabled = false,
    lazy = false,
    build = ":call doge#install()",
    cmd = "DogeGenerate",
    dependencies = {
      { "AstroNvim/astroui", opts = { icons = { Annotation = "󰷉" } } },
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.options then opts.options = {} end
          if not opts.options.g then opts.options.g = {} end
          if not opts.options.opt then opts.options.opt = {} end
          opts.options.g.doge_enable_mappings = false
          opts.options.g.doge_comment_interactive = false
          -- Workaround for Doge's cmdheight requirement
          if opts.options.g.doge_comment_interactive and opts.options.opt.cmdheight == 0 then
            opts.options.opt.cmdheight = 1
          end
          local maps = assert(opts.mappings)
          local prefix = "<Leader>A"
          maps.n[prefix] = { desc = require("astroui").get_icon("Annotation", 1, true) .. "Annotation" }
          maps.n[prefix .. "d"] = {
            "<Plug>(doge-generate)",
            desc = "Generate annotation with Doge",
          }
          if not opts.options.g.doge_enable_mappings and opts.options.g.doge_comment_interactive then
            local jump_forward_mapping = "<M-a>"
            local jump_backward_mapping = "<M-A>"
            opts.options.g.doge_mapping_comment_jump_forward = jump_forward_mapping
            opts.options.g.doge_mapping_comment_jump_backward = jump_backward_mapping
            for _, mode in ipairs { "n", "i", "s" } do
              maps[mode][jump_forward_mapping] = { "<Plug>(doge-comment-jump-forward)" }
              maps[mode][jump_backward_mapping] = { "<Plug>(doge-comment-jump-backward)" }
            end
          end
        end,
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    event = "VeryLazy",
    optional = true,
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
