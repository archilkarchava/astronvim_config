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
    "which-key.nvim",
    opts = {
      ---@type false | "classic" | "modern" | "helix"
      preset = "helix",
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
    cond = true,
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
            maps[mode]["<leader>r"] =
              { function() require("various-textobjs").restOfParagraph() end, desc = "Rest of paragraph" }
            maps[mode]["R"] =
              { function() require("various-textobjs").restOfIndentation() end, desc = "Rest of indentation" }
            maps[mode]["|"] = { function() require("various-textobjs").column() end, desc = "Column" }
            maps[mode]["iK"] = { function() require("various-textobjs").key "inner" end, desc = "Inside key" }
            maps[mode]["aK"] = { function() require("various-textobjs").key "outer" end, desc = "Around key" }
            maps[mode]["iv"] = { function() require("various-textobjs").value "inner" end, desc = "Inside value" }
            maps[mode]["av"] = { function() require("various-textobjs").value "outer" end, desc = "Around value" }
            maps[mode]["im"] =
              { function() require("various-textobjs").chainMember "inner" end, desc = "Inside chain member" }
            maps[mode]["am"] =
              { function() require("various-textobjs").chainMember "outer" end, desc = "Around chain member" }
            maps[mode]["iS"] = { function() require("various-textobjs").subword "inner" end, desc = "Inside subword" }
            maps[mode]["aS"] = { function() require("various-textobjs").subword "outer" end, desc = "Around subword" }
          end
        end,
      },
    },
  },
  {
    "ggandor/leap.nvim",
    cond = true,
    event = "VeryLazy",
    dependencies = {
      "tpope/vim-repeat",
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          for _, mode in ipairs { "n", "x", "o" } do
            maps[mode]["s"] = { "<Plug>(leap)", desc = "Leap" }
            maps[mode]["gz"] = { "<Plug>(leap-from-window)", desc = "Leap from window" }
          end

          for _, mode in ipairs { "n", "o" } do
            maps[mode]["gs"] = { function() require("leap.remote").action() end, desc = "Leap remote" }
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
    "ggandor/flit.nvim",
    cond = true,
    event = "VeryLazy",
    dependencies = {
      { "ggandor/leap.nvim" },
    },
  },
  {
    "folke/flash.nvim",
    cond = true,
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
    "jake-stewart/multicursor.nvim",
    cond = true,
    branch = "1.0",
    event = "VeryLazy",
    opts = {
      signs = false,
    },
    config = function(_, opts)
      local mc = require "multicursor-nvim"
      mc.setup(opts)

      -- Customize how cursors look.
      vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "Cursor" })
      vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
      vim.api.nvim_set_hl(0, "MultiCursorSign", { link = "SignColumn" })
      vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
      vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      vim.api.nvim_set_hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
    specs = {
      {
        "echasnovski/mini.bracketed",
        optional = true,
        opts = {
          -- Undo mapping interferes with multicursor.nvim, so we disable it
          undo = { suffix = "", options = {} },
        },
      },
      {
        "which-key.nvim",
        optional = true,
        opts = function(_, opts)
          local existing_filter = opts.filter or function() return true end
          opts.filter = function(mapping)
            if string.lower(mapping.lhs) == "<c-c>" then return false end
            if not existing_filter(mapping) then return false end
            -- For some reason, in multicursor mode vi and va mappings don't work properly with which-key if they are not default mappings
            local modes = { x = true, v = true, o = true }
            local lhs_values = { i = true, a = true }

            return not (modes[mapping.mode] and lhs_values[mapping.lhs])
          end
        end,
      },
      {
        "nvim-autopairs",
        optional = true,
        dependencies = {
          {
            "AstroNvim/astrocore",
            ---@type AstroCoreOpts
            opts = {
              autocmds = {
                autopairs = {
                  {
                    event = "InsertEnter",
                    callback = function()
                      local mc = require "multicursor-nvim"
                      local npairs = require "nvim-autopairs"
                      if mc.hasCursors() then
                        npairs.disable()
                      else
                        npairs.enable()
                      end
                    end,
                  },
                },
              },
            },
          },
        },
      },
    },
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local mc = require "multicursor-nvim"

          opts.autocmds.multicursor_buf_siwtch = {
            {
              event = "BufLeave",
              callback = function()
                if mc.hasCursors() then mc.clearCursors() end
              end,
            },
          }

          local maps = assert(opts.mappings)

          ---@param f fun()
          local function with_count(f)
            return function()
              for _ = 1, vim.v.count1 do
                f()
              end
            end
          end

          local main_map = vim.g.vscode and "<D-d>" or "<D-s>"
          local chord_prefix = vim.g.vscode and "<D-k>" or "<D-x>"
          for _, mode in ipairs { "n", "v" } do
            -- Add cursors above/below the main cursor.
            local add_cursor_above = { with_count(function() mc.lineAddCursor(-1) end), desc = "Add cursor above" }
            local skip_cursor_above = { with_count(function() mc.lineSkipCursor(-1) end), desc = "Skip cursor above" }
            local add_cursor_below = { with_count(function() mc.lineAddCursor(1) end), desc = "Add cursor below" }
            local skip_cursor_below = { with_count(function() mc.lineSkipCursor(1) end), desc = "Skip cursor below" }
            maps[mode]["<D-M-k>"] = add_cursor_above
            maps[mode]["<D-M-j>"] = add_cursor_below
            maps[mode]["<leader><D-M-k>"] = skip_cursor_above
            maps[mode]["<leader><D-M-j>"] = skip_cursor_below

            -- Add a cursor and jump to the next word under cursor.
            maps[mode][main_map] = {
              with_count(function() mc.matchAddCursor(1) end),
              desc = "Add cursor and jump to next word",
            }
            -- Add a cursor and jump to the previous word under cursor.
            maps[mode][string.upper(main_map)] =
              { with_count(function() mc.matchAddCursor(-1) end), desc = "Add cursor and jump to previous word" }

            -- Jump to the next word under cursor but do not add a cursor.
            maps[mode][chord_prefix .. main_map] =
              { with_count(function() mc.matchSkipCursor(1) end), desc = "Skip cursor and jump to next word" }
            -- Jump to the previous word under cursor but do not add a cursor.
            maps[mode][chord_prefix .. string.upper(main_map)] =
              { with_count(function() mc.matchSkipCursor(-1) end), desc = "Skip cursor and jump to previous word" }

            maps[mode]["<D-L>"] = { mc.matchAllAddCursors, desc = "Add cursors to all matches" }

            -- Rotate the main cursor.
            maps[mode]["<left>"] = {
              function()
                if mc.hasCursors() then
                  with_count(mc.prevCursor)()
                else
                  vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes(vim.v.count1 .. "<left>", true, false, true),
                    "n",
                    false
                  )
                end
              end,
              desc = "Rotate main cursor (previous)",
            }
            maps[mode]["<right>"] = {
              function()
                if mc.hasCursors() then
                  with_count(mc.nextCursor)()
                else
                  vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes(vim.v.count1 .. "<right>", true, false, true),
                    "n",
                    false
                  )
                end
              end,
              desc = "Rotate main cursor (next)",
            }

            -- Delete the main cursor.
            maps[mode][chord_prefix .. "<D-x>"] = { mc.deleteCursor, desc = "Delete cursor" }

            maps[mode][chord_prefix .. "<D-z>"] = { mc.toggleCursor, desc = "Toggle cursor" }

            -- clone every cursor and disable the originals
            maps[mode][chord_prefix .. "<D-Z>"] = { mc.duplicateCursors, desc = "Duplicate cursors" }

            -- Jumplist support
            maps[mode]["<c-i>"] = { mc.jumpForward, desc = "Jump forward" }
            maps[mode]["<c-o>"] = { mc.jumpBackward, desc = "Jump backward" }
          end

          -- Add and remove cursors with control + left click.
          maps.n["<M-LeftMouse>"] = { mc.handleMouse, desc = "Add cursor" }

          maps.n["<esc>"] = function()
            if not mc.cursorsEnabled() then
              mc.enableCursors()
            elseif mc.hasCursors() then
              mc.clearCursors()
            end
          end

          -- Align cursor columns.
          maps.n[chord_prefix .. "<D-a>"] = { mc.alignCursors, desc = "Align cursors" }

          -- Split visual selections by regex.
          maps.v[chord_prefix] = { mc.splitCursors, desc = "Split selections" }

          -- Append/insert for each line of visual selections.
          maps.v["I"] = { mc.insertVisual, desc = "Insert line" }
          maps.v["A"] = { mc.appendVisual, desc = "Append line" }

          -- match new cursors within visual selections by regex.
          maps.v["M"] = { mc.matchCursors, desc = "Match cursors" }

          -- Rotate visual selection contents.
          maps.v["<leader>t"] = { function() mc.transposeCursors(1) end, desc = "Transpose selections (forward)" }
          maps.v["<leader>T"] = { function() mc.transposeCursors(-1) end, desc = "Transpose selections (backward)" }
        end,
      },
    },
  },
  {
    "wellle/targets.vim",
    cond = true,
    event = "VeryLazy",
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = {
          autocmds = {
            targets = {
              {
                event = "User",
                pattern = "targets#mappings#user",
                callback = function()
                  vim.fn["targets#mappings#extend"] {
                    b = {
                      pair = {
                        {
                          o = "(",
                          c = ")",
                        },
                      },
                    },
                    r = {
                      pair = {
                        {
                          o = "[",
                          c = "]",
                        },
                      },
                    },
                  }
                end,
              },
            },
          },
        },
      },
    },
    specs = {
      {
        "nvim-treesitter",
        optional = true,
        opts = function(_, opts)
          local select_keymaps = vim.tbl_get(opts, "textobjects", "select", "keymaps")
          if not select_keymaps then return end
          select_keymaps["iA"] = select_keymaps["ia"]
          select_keymaps["aA"] = select_keymaps["aa"]
          select_keymaps["ia"] = nil
          select_keymaps["aa"] = nil
        end,
      },
    },
    init = function()
      vim.g.targets_aiAI = "aIAi"
      vim.g.targets_seekRanges = "cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA"
    end,
  },
  {
    "echasnovski/mini.ai",
    cond = true,
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
    cond = true,
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
    cond = true,
    event = "VeryLazy",
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = {
          mappings = {
            n = {
              ["gr"] = { function() require("substitute").operator() end, desc = "Substitute" },
              ["gri"] = {
                function()
                  require("substitute").operator {
                    motion = "i",
                  }
                end,
                desc = "Substitute inside",
              },
              ["gra"] = {
                function()
                  require("substitute").operator {
                    motion = "a",
                  }
                end,
                desc = "Substitute around",
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
    init = function()
      pcall(vim.keymap.del, "n", "gra")
      pcall(vim.keymap.del, "n", "gri")
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
    version = false,
    optional = true,
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 200,
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
                remap = true,
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
    cond = true,
    event = "VeryLazy",
    optional = true,
    dependencies = {
      { "AstroNvim/astroui", opts = { icons = { Log = "󰹈" } } },
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          local prefix = "<Leader>L"
          for _, mode in ipairs { "n", "x" } do
            maps[mode][prefix] = { desc = require("astroui").get_icon("Log", 1, true) .. "Log" }
            maps[mode][prefix .. "v"] = {
              function() require("chainsaw").variableLog() end,
              desc = "Variable log",
            }
            maps[mode][prefix .. "o"] = {
              function() require("chainsaw").objectLog() end,
              desc = "Object log",
            }
            maps[mode][prefix .. "t"] = {
              function() require("chainsaw").typeLog() end,
              desc = "Type log",
            }
            maps[mode][prefix .. "a"] = {
              function() require("chainsaw").assertLog() end,
              desc = "Assert log",
            }
            maps[mode][prefix .. "e"] = {
              function() require("chainsaw").emojiLog() end,
              desc = "Emoji log",
            }
            maps[mode][prefix .. "m"] = {
              function() require("chainsaw").messageLog() end,
              desc = "Message log",
            }
            maps[mode][prefix .. "T"] = {
              function() require("chainsaw").timeLog() end,
              desc = "Time log",
            }
            maps[mode][prefix .. "d"] = {
              function() require("chainsaw").debugLog() end,
              desc = "Debug log",
            }
            maps[mode][prefix .. "s"] = {
              function() require("chainsaw").stacktraceLog() end,
              desc = "Stacktrace log",
            }
            maps[mode][prefix .. "c"] = {
              function() require("chainsaw").clearLog() end,
              desc = "Clear log",
            }
            maps[mode][prefix .. "r"] = {
              function() require("chainsaw").removeLogs() end,
              desc = "Remove all log statements created by Chainsaw",
            }
          end
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
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)
          for _, mode in ipairs { "n", "i", "x" } do
            for i = 1, 9 do
              maps[mode]["<M-" .. i .. ">"] =
                { function() require("harpoon"):list():select(i) end, desc = "Harpoon select entry #" .. i }
            end
          end
        end,
      },
    },
  },
  {
    "folke/trouble.nvim",
    event = "VeryLazy",
    optional = true,
  },
  {
    "akinsho/git-conflict.nvim",
    event = "User AstroGitFile",
    version = "*",
    opts = {},
  },
  {
    "kawre/leetcode.nvim",
    lazy = true,
    optional = true,
    opts = {
      lang = "typescript",
    },
  },
  {
    "package-info.nvim",
    enabled = false,
    opts = {
      autostart = false,
    },
  },
  {
    "booperlv/nvim-gomove",
    cond = true,
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = {
          mappings = {
            n = {
              ["<M-S-Up>"] = { "<Plug>GoNSDUp", desc = "Hello" },
              ["<M-K>"] = { "<Plug>GoNSDUp", desc = "Hello" },
              ["<M-S-Down>"] = { "<Plug>GoNSDDown", desc = "Hello" },
              ["<M-J>"] = { "<Plug>GoNSDDown", desc = "Hello" },
            },
            x = {
              ["<M-S-Up>"] = { "<Plug>GoVSDUp", desc = "Hello" },
              ["<M-K>"] = { "<Plug>GoVSDUp", desc = "Hello" },
              ["<M-S-Down>"] = { "<Plug>GoVSDDown", desc = "Hello" },
              ["<M-J>"] = { "<Plug>GoVSDDown", desc = "Hello" },
            },
          },
        },
      },
    },
    opts = {
      -- whether or not to map default key bindings, (true/false)
      map_defaults = false,
      -- whether or not to reindent lines moved vertically (true/false)
      reindent = true,
      -- whether or not to undojoin same direction moves (true/false)
      undojoin = true,
      -- whether to not to move past end column when moving blocks horizontally, (true/false)
      move_past_end_col = false,
    },
  },
  {
    "smart-splits.nvim",
    optional = true,
    build = "./kitty/install-kittens.bash",
  },
  {
    "neogit",
    optional = true,
    opts = function(_, opts)
      local util = require "util"
      opts.graph_style = util.is_kitty() and "kitty" or "unicode"
    end,
  },
  {
    "better-escape.nvim",
    enabled = false,
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
