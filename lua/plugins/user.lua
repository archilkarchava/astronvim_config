-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

local util_keymaps = require "util.keymaps"
local normalize_keymap = util_keymaps.normalize_keymap
local chord_prefix = util_keymaps.chord_prefix()

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
    "nvim-cmp",
    optional = true,
    opts = function(_, opts)
      local cmp = require "cmp"
      local toggle_cmp = cmp.mapping {
        i = function()
          if cmp.visible() then
            cmp.abort()
          else
            cmp.complete()
          end
        end,
      }
      opts.mapping[normalize_keymap "<D-i>"] = toggle_cmp
      local orig_format = vim.tbl_get(opts, "formatting", "format") or function() end
      opts.formatting = opts.formatting or {}
      opts.formatting.format = function(entry, item)
        item.abbr = string.sub(item.abbr, 1, 25)
        return orig_format(entry, item)
      end
    end,
  },
  {
    "blink.cmp",
    optional = true,
    opts = function(_, opts)
      local astrocore = require "astrocore"
      local blink_default_config = require "blink.cmp.config"
      if not opts.fuzzy then opts.fuzzy = {} end
      local orig_sorts = opts.fuzzy.sorts or blink_default_config.fuzzy.sorts
      local function deprioritize_emmet(a, b)
        if a.source_name ~= "LSP" or b.source_name ~= "LSP" then return end

        if not a.client_name or not b.client_name then return end

        if a.client_name == "emmet_language_server" and b.client_name ~= "emmet_language_server" then
          return false
        elseif a.client_name ~= "emmet_language_server" and b.client_name == "emmet_language_server" then
          return true
        else
          return nil
        end
      end
      local existing_transform = opts.transform_items or function(_, items) return items end
      local function remove_duplicate_snippets(_, items)
        local seen_snippets = {}
        return vim.tbl_filter(function(item)
          if item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
            if seen_snippets[item.label] then
              return false
            else
              seen_snippets[item.label] = true
            end
          end
          return true
        end, items)
      end
      local function transform_items(entry, items)
        return remove_duplicate_snippets(entry, existing_transform(entry, items))
      end
      return astrocore.extend_tbl(opts, {
        enabled = function()
          return not vim.tbl_contains({ "copilot-chat" }, vim.bo.filetype)
            and vim.bo.buftype ~= "prompt"
            and vim.b.completion ~= false
        end,
        keymap = {
          [normalize_keymap "<D-i>"] = { "show", "hide", "fallback" },
        },
        completion = { list = { selection = { preselect = true } } },
        fuzzy = {
          sorts = vim.list_extend({ deprioritize_emmet }, orig_sorts),
        },
        sources = {
          transform_items = transform_items,
        },
      })
    end,
    specs = {
      { "magazine.nvim", enabled = false },
      { "cmp-cmdline", enabled = false },
      {
        "noice.nvim",
        optional = true,
        opts = {
          routes = {
            {
              filter = {
                event = "msg_show",
                any = {
                  { find = "Error detected while processing WinScrolled Autocommands for" },
                  { find = "blink.cmp/lua/blink/cmp/lib/window/init.lua:314: Invalid window id" },
                },
              },
              opts = { skip = true },
            },
          },
        },
      },
    },
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
            maps[mode]["<Leader>r"] =
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
      vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = vim.g.vscode and "FakeVisual" or "Visual" })
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

          opts.autocmds.multicursor_buf_switch = {
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

          local main_map = normalize_keymap "<D-d>"
          for _, mode in ipairs { "n", "v" } do
            -- Add cursors above/below the main cursor.
            local add_cursor_above = { with_count(function() mc.lineAddCursor(-1) end), desc = "Add cursor above" }
            local skip_cursor_above = { with_count(function() mc.lineSkipCursor(-1) end), desc = "Skip cursor above" }
            local add_cursor_below = { with_count(function() mc.lineAddCursor(1) end), desc = "Add cursor below" }
            local skip_cursor_below = { with_count(function() mc.lineSkipCursor(1) end), desc = "Skip cursor below" }
            maps[mode][normalize_keymap "<D-M-k>"] = add_cursor_above
            maps[mode][normalize_keymap "<D-M-j>"] = add_cursor_below
            maps[mode][chord_prefix .. normalize_keymap "<D-M-k>"] = skip_cursor_above
            maps[mode][chord_prefix .. normalize_keymap "<D-M-j>"] = skip_cursor_below
            maps[mode][normalize_keymap "<D-M-Up>"] = add_cursor_above
            maps[mode][normalize_keymap "<D-M-Down>"] = add_cursor_below
            maps[mode][chord_prefix .. normalize_keymap "<D-M-Up>"] = skip_cursor_above
            maps[mode][chord_prefix .. normalize_keymap "<D-M-Down>"] = skip_cursor_below

            -- Add a cursor and jump to the next word under cursor.
            maps[mode][main_map] = {
              with_count(function() mc.matchAddCursor(1) end),
              desc = "Add cursor and jump to next word",
            }
            -- Add a cursor and jump to the previous word under cursor.
            maps[mode][main_map:upper()] =
              { with_count(function() mc.matchAddCursor(-1) end), desc = "Add cursor and jump to previous word" }

            -- Jump to the next word under cursor but do not add a cursor.
            maps[mode][chord_prefix .. main_map] =
              { with_count(function() mc.matchSkipCursor(1) end), desc = "Skip cursor and jump to next word" }
            -- Jump to the previous word under cursor but do not add a cursor.
            maps[mode][chord_prefix .. main_map:upper()] =
              { with_count(function() mc.matchSkipCursor(-1) end), desc = "Skip cursor and jump to previous word" }

            maps[mode][normalize_keymap "<D-L>"] = { mc.matchAllAddCursors, desc = "Add cursors to all matches" }

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
            maps[mode][chord_prefix .. normalize_keymap "<D-x>"] = { mc.deleteCursor, desc = "Delete cursor" }

            maps[mode][chord_prefix .. normalize_keymap "<D-z>"] = { mc.toggleCursor, desc = "Toggle cursor" }

            -- clone every cursor and disable the originals
            maps[mode][chord_prefix .. normalize_keymap "<D-Z>"] = { mc.duplicateCursors, desc = "Duplicate cursors" }
          end

          -- Jumplist support
          if not vim.g.vscode then
            maps.n["<c-i>"] = { mc.jumpForward, desc = "Jump forward" }
            maps.n["<c-o>"] = { mc.jumpBackward, desc = "Jump backward" }
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
          maps.n[chord_prefix .. normalize_keymap "<D-a>"] = { mc.alignCursors, desc = "Align cursors" }

          -- Split visual selections by regex.
          maps.v[chord_prefix] = { mc.splitCursors, desc = "Split selections" }

          -- Append/insert for each line of visual selections.
          maps.v["I"] = { mc.insertVisual, desc = "Insert line" }
          maps.v["A"] = { mc.appendVisual, desc = "Append line" }

          -- match new cursors within visual selections by regex.
          maps.v["M"] = { mc.matchCursors, desc = "Match cursors" }

          -- Rotate visual selection contents.
          maps.v["<Leader>t"] = { function() mc.transposeCursors(1) end, desc = "Transpose selections (forward)" }
          maps.v["<Leader>T"] = { function() mc.transposeCursors(-1) end, desc = "Transpose selections (backward)" }
        end,
      },
    },
  },
  {
    "nvim-surround",
    optional = true,
    cond = true,
  },
  {
    "wellle/targets.vim",
    enabled = false,
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
      -- vim.g.targets_aiAI = "aIAi"
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
    "mini.move",
    optional = true,
    cond = true,
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
    "nvim-lspconfig",
    version = "*",
    optional = true,
  },
  {
    "jedrzejboczar/exrc.nvim",
    event = "VeryLazy",
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
      lsp = { auto_setup = false },
      on_vim_enter = false,
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
    "gitsigns.nvim",
    version = false,
    optional = true,
    opts = function(_, opts)
      local astrocore = require "astrocore"
      ---@type fun(bufnr: number)
      local original_on_attach = opts.on_attach or function() end
      local modified_opts = {
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "right_align", -- 'eol' | 'overlay' | 'right_align'
          delay = 200,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        on_attach = function(bufnr)
          original_on_attach(bufnr)
          local maps = astrocore.empty_map_table()
          local lhs = "<M-D-z>"
          for _, mode in ipairs { "n", "i" } do
            maps[mode][lhs] = { function() require("gitsigns").reset_hunk() end, desc = "Reset Git hunk" }
          end
          maps.v[lhs] = {
            function() require("gitsigns").reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
            desc = "Reset Git hunk",
          }
          astrocore.set_mappings(maps, { buffer = bufnr })
        end,
      }
      return astrocore.extend_tbl(opts, modified_opts)
    end,
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = {
          mappings = {
            n = {
              ["<Leader>gB"] = { "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle inline git blame" },
            },
          },
        },
      },
    },
    specs = {
      {
        "nvim-ufo",
        optional = true,
        opts = function(_, opts)
          ---@type fun(bufnr: number, filetype: string, buftype: string): string | table<number, string>
          local original_provider_selector = opts.provider_selector or function() end
          opts.provider_selector = function(bufnr, filetype, buftype)
            -- Workaround to fix gitsigns inline hunk preview
            if buftype == "nofile" and filetype ~= nil and filetype ~= "" then return "" end
            return original_provider_selector(bufnr, filetype, buftype)
          end
        end,
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
    "oil.nvim",
    optional = true,
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)
          local toggle_oil_rhs = { function() require("oil").toggle_float() end, desc = "Toggle Oil (File explorer)" }
          for _, mode in ipairs { "n", "x", "o", "i" } do
            maps[mode]["<M-e>"] = toggle_oil_rhs
          end
        end,
      },
    },
    opts = function(_, opts)
      if not opts.keymaps then opts.keymaps = {} end
      local open_horizontal_split_rhs =
        { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" }
      local open_vertical_split_rhs =
        { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" }
      opts.keymaps["<C-h>"] = false
      opts.keymaps["<C-s>"] = false
      opts.keymaps["<C-\\>"] = open_horizontal_split_rhs
      opts.keymaps["<C-S-\\>"] = open_vertical_split_rhs
      opts.keymaps[normalize_keymap "<D-\\>"] = open_horizontal_split_rhs
      opts.keymaps[normalize_keymap "<D-S-\\>"] = open_vertical_split_rhs
    end,
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
          local chainsaw = require "chainsaw"
          for _, mode in ipairs { "n", "x" } do
            maps[mode][prefix] = { desc = require("astroui").get_icon("Log", 1, true) .. "Log" }
            local variable_log_rhs = {
              function() chainsaw.variableLog() end,
              desc = "Variable log",
            }
            maps[mode]["<C-M-l>"] = variable_log_rhs
            maps[mode][prefix .. "v"] = variable_log_rhs
            maps[mode][prefix .. "o"] = {
              function() chainsaw.objectLog() end,
              desc = "Object log",
            }
            maps[mode][prefix .. "t"] = {
              function() chainsaw.typeLog() end,
              desc = "Type log",
            }
            maps[mode][prefix .. "a"] = {
              function() chainsaw.assertLog() end,
              desc = "Assert log",
            }
            maps[mode][prefix .. "e"] = {
              function() chainsaw.emojiLog() end,
              desc = "Emoji log",
            }
            maps[mode][prefix .. "m"] = {
              function() chainsaw.messageLog() end,
              desc = "Message log",
            }
            maps[mode][prefix .. "T"] = {
              function() chainsaw.timeLog() end,
              desc = "Time log",
            }
            maps[mode][prefix .. "d"] = {
              function() chainsaw.debugLog() end,
              desc = "Debug log",
            }
            maps[mode][prefix .. "s"] = {
              function() chainsaw.stacktraceLog() end,
              desc = "Stacktrace log",
            }
            maps[mode][prefix .. "c"] = {
              function() chainsaw.clearLog() end,
              desc = "Clear log",
            }
            maps[mode][prefix .. "r"] = {
              function() chainsaw.removeLogs() end,
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
    "rhysd/conflict-marker.vim",
    event = "User AstroGitFile",
    cmd = { "ConflictMarkerOurselves", "ConflictMarkerThemselves", "ConflictMarkerBoth", "ConflictMarkerNone" },
    init = function()
      -- Clear default conflict marker highlight group
      vim.g.conflict_marker_highlight_group = ""

      -- Include text after begin and end markers
      vim.g.conflict_marker_begin = "^<<<<<<<\\+ .*$"
      vim.g.conflict_marker_common_ancestors = "^|||||||\\+ .*$"
      vim.g.conflict_marker_end = "^>>>>>>>\\+ .*$"
    end,
    specs = {
      {
        "AstroNvim/astrocore",
        optional = true,
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local shade_color = require("util.highlight").shade_color
          local function generate_conflict_marker_highlights(is_light_bg)
            local ConflictMarkerOursBg = is_light_bg and "#f2d2cf" or "#562C30"
            local ConflictMarkerTheirsBg = is_light_bg and "#d4e4c9" or "#314753"
            local ConflictMarkerCommonAncestorsHunkBg = is_light_bg and "#c9d4e4" or "#754a81"
            local shade_direction = is_light_bg and "light" or "dark"
            local shade_factor = is_light_bg and -30 or 30

            return {
              ConflictMarkerOurs = { bg = ConflictMarkerOursBg, bold = true },
              ConflictMarkerTheirs = { bg = ConflictMarkerTheirsBg, bold = true },
              ConflictMarkerBegin = { bg = shade_color(ConflictMarkerOursBg, shade_factor, shade_direction) },
              ConflictMarkerEnd = { bg = shade_color(ConflictMarkerTheirsBg, shade_factor, shade_direction) },
              ConflictMarkerCommonAncestorsHunk = { bg = ConflictMarkerCommonAncestorsHunkBg },
              ConflictMarkerCommonAncestors = {
                bg = shade_color(ConflictMarkerCommonAncestorsHunkBg, shade_factor, shade_direction),
              },
            }
          end

          local function set_highlights()
            local is_light_bg = vim.opt.background:get() == "light"
            local highlights_to_apply = generate_conflict_marker_highlights(is_light_bg)
            for name, definition in pairs(highlights_to_apply) do
              vim.api.nvim_set_hl(0, name, definition)
            end
          end

          set_highlights()
          if not opts.autocmds then opts.autocmds = {} end
          opts.autocmds.conflict_marker_highlights = {
            {
              event = "ColorScheme",
              desc = "Apply conflict marker highlights",
              callback = set_highlights,
            },
          }
        end,
      },
    },
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
              ["<M-S-Up>"] = { "<Plug>GoNSDUp", desc = "Copy line above" },
              ["<M-K>"] = { "<Plug>GoNSDUp", desc = "Copy line above" },
              ["<M-S-Down>"] = { "<Plug>GoNSDDown", desc = "Copy line below" },
              ["<M-J>"] = { "<Plug>GoNSDDown", desc = "Copy line below" },
            },
            x = {
              ["<M-S-Up>"] = { "<Plug>GoVSDUp", desc = "Copy selection above" },
              ["<M-K>"] = { "<Plug>GoVSDUp", desc = "Copy selection above" },
              ["<M-S-Down>"] = { "<Plug>GoVSDDown", desc = "Copy selection below" },
              ["<M-J>"] = { "<Plug>GoVSDDown", desc = "Copy selection below" },
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
      local util = require "util.terminal"
      opts.graph_style = util.is_kitty() and "kitty" or "unicode"
      opts.process_spinner = false
      opts.console_timeout = 500
    end,
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)
          maps.n["<Leader>pG"] = {
            function() vim.cmd.Neogit("cwd=" .. vim.fn.stdpath "config") end,
            desc = "Open Neogit (AstroNvim config)",
          }
          maps.n["<Leader>gH"] = { "<cmd>NeogitLogCurrent<cr>", desc = "Git commits (current file neogit)" }
          for _, mode in ipairs { "n", "v", "s", "x", "i" } do
            maps[mode][normalize_keymap "<D-0>"] = {
              function()
                if vim.bo.filetype == "NeogitStatus" then
                  require("neogit.lib.util").safe_win_close(0, true)
                else
                  vim.cmd.Neogit()
                end
              end,
              desc = "Open Neogit Tab Page",
            }
          end
        end,
      },
    },
  },
  {
    "nvim-bqf",
    optional = true,
    opts = {
      func_map = {
        openc = "<CR>",
        open = "o",
      },
    },
    dependencies = {
      {
        "junegunn/fzf",
        run = ":call fzf#install()",
      },
    },
  },
  {
    "nvim-surround",
    optional = true,
    opts = {
      keymaps = {
        insert = false,
        insert_line = false,
      },
    },
  },
  {
    "rgroli/other.nvim",
    cond = true,
    cmd = {
      "Other",
      "OtherTabNew",
      "OtherSplit",
      "OtherVSplit",
      "OtherClear",
    },
    main = "other-nvim",
    dependencies = {
      {
        "AstroNvim/astrocore",
        optional = true,
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          for _, mode in ipairs { "n", "x", "i" } do
            opts.mappings[mode]["<M-o>"] = { "<cmd>Other<cr>", desc = "Go to other (related) file" }
            opts.mappings[mode]["<M-O>"] =
              { "<cmd>OtherVSplit<cr>", desc = "Go to other (related) file (vertical split)" }
          end
        end,
      },
    },
    opts = {
      showMissingFiles = false,
      mappings = {
        "golang",
        "python",
        "rust",
        ---- C/C++
        "c",
        {
          pattern = "(.*).cpp$",
          context = "header",
          target = "%1.h",
        },
        {
          pattern = "(.*).h$",
          context = "implementation",
          target = "%1.cpp",
        },
        ---- TypeScript/JavaScript
        "angular",
        "react",
        {
          pattern = "(.*).d.ts$",
          context = "declaration-test",
          target = "%1.test-d.ts",
        },
        {
          pattern = "(.*).test%-d.ts$",
          target = {
            {
              context = "declaration",
              target = "%1.d.ts",
            },
            {
              context = "implementation",
              target = "%1.ts",
            },
          },
        },
        {
          pattern = "(.*)/([a-zA-Z0-9%-]*).([tj]sx?)$",
          target = "%1/__tests__/%2.spec.%3",
          context = "test",
        },
        {
          pattern = "(.*)/([a-zA-Z0-9%-]*).([tj]sx?)$",
          target = "%1/__test__/%2.spec.%3",
          context = "test",
        },
        {
          pattern = "(.*)/__tests?__/(.*).spec.([tj]sx?)$",
          target = "%1/%2.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/([a-zA-Z0-9%-]*).([tj]sx?)$",
          target = "%1/__tests__/%2.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/([a-zA-Z0-9%-]*).([tj]sx?)$",
          target = "%1/__test__/%2.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/([a-zA-Z0-9%-]*).([tj]sx?)$",
          target = "%1/../__tests__/%2.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/([a-zA-Z0-9%-]*).([tj]sx?)$",
          target = "%1/../__test__/%2.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/__tests?__/(.*).test.([tj]sx?)$",
          target = "%1/%2.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/__tests?__/(.*).test.([tj]sx?)$",
          target = "%1/%2/%2.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/([a-zA-Z0-9%-]*).([tj]sx?)$",
          target = "%1/__tests__/%2.integration.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/([a-zA-Z0-9%-]*).([tj]sx?)$",
          target = "%1/__test__/%2.integration.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/([a-zA-Z0-9%-]*).([tj]sx?)$",
          target = "%1/../__tests__/%2.integration.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/([a-zA-Z0-9%-]*).([tj]sx?)$",
          target = "%1/../__test__/%2.integration.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/__tests?__/(.*).integration.test.([tj]sx?)$",
          target = "%1/%2.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/__tests?__/(.*).integration.test.([tj]sx?)$",
          target = "%1/%2/%2.%3",
          context = "implementation",
        },
        {
          pattern = "(.*).([tj]sx?)$",
          target = "%1.integration.test.%2",
          context = "test",
        },
        {
          pattern = "(.*).integration.test.([tj]sx?)$",
          target = "%1.%2",
          context = "implementation",
        },
        {
          pattern = "(.*).([tj]sx?)$",
          target = "%1.integration.spec.%2",
          context = "test",
        },
        {
          pattern = "(.*).integration.spec.([tj]sx?)$",
          target = "%1.%2",
          context = "implementation",
        },
        {
          pattern = "(.*)/__tests?__/(.*).test.([tj]sx?)$",
          target = "%1/hooks/%2.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/__tests?__/(.*).test.([tj]sx?)$",
          target = "%1/helpers/%2.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/__tests?__/(.*).spec.([tj]sx?)$",
          target = "%1/hooks/%2.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/__tests?__/(.*).spec.([tj]sx?)$",
          target = "%1/helpers/%2.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/(.*)/index.([tj]sx?)$",
          target = "%1/__tests__/%2.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/(.*)/index.([tj]sx?)$",
          target = "%1/__test__/%2.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/(.*)/index.([tj]sx?)$",
          target = "%1/__tests__/%2.spec.%3",
          context = "test",
        },
        {
          pattern = "(.*)/(.*)/index.([tj]sx?)$",
          target = "%1/__test__/%2.spec.%3",
          context = "test",
        },
        {
          pattern = "(.*)/__tests?__/(.*).test.([tj]sx?)$",
          target = "%1/%2/index.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/__tests?__/(.*).spec.([tj]sx?)$",
          target = "%1/%2/index.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/(.*)/index.([tj]sx?)$",
          target = "%1/%2.test.%3",
          context = "test",
        },
        {
          pattern = "(.*)/(.*)/index.([tj]sx?)$",
          target = "%1/%2.spec.%3",
          context = "test",
        },
        {
          pattern = "(.*)/(.*).test.([tj]sx?)$",
          target = "%1/%2/index.%3",
          context = "implementation",
        },
        {
          pattern = "(.*)/(.*).spec.([tj]sx?)$",
          target = "%1/%2/index.%3",
          context = "implementation",
        },
        {
          pattern = "(.*).([tj]s)x?$",
          target = "%1.test.%2",
          context = "test",
        },
        {
          pattern = "(.*).test.([tj]s)$",
          target = "%1.%2x",
          context = "implementation",
        },
        {
          pattern = "(.*).([tj]s)$",
          target = "%1.test.%2x",
          context = "test",
        },
        {
          pattern = "(.*).test.([tj]s)x?$",
          target = "%1.%2",
          context = "implementation",
        },
      },
    },
  },
  {
    "mini.files",
    event = "VeryLazy",
    optional = true,
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)
          local minifiles = require "mini.files"
          local prev_buf_id_tab_var_name = "minifiles_prev_buf_id"
          local toggle_mini_files_rhs = {
            function()
              if not minifiles.close() then minifiles.open() end
            end,
            desc = "Explorer",
          }
          ---@param buf_name string
          local function get_parent_dir(buf_name) return vim.fn.fnamemodify(buf_name, ":h") end

          local focus_file_buffer = function(buf_id)
            if buf_id == nil then return end
            local buf_name = vim.api.nvim_buf_get_name(buf_id)
            if vim.fn.filereadable(buf_name) == 0 then return end
            local dirname = get_parent_dir(buf_name)
            local branch = { dirname, buf_name }
            minifiles.set_branch(branch)
            minifiles.reveal_cwd()
          end
          local open_current_file_in_explorer = function()
            local cur_buf_id = vim.api.nvim_get_current_buf()
            minifiles.open()
            focus_file_buffer(cur_buf_id)
          end
          local focus_current_mini_files_rhs = {
            function()
              local explorer_state = minifiles.get_explorer_state()
              if explorer_state == nil then
                open_current_file_in_explorer()
                return
              end
              focus_file_buffer(vim.t[prev_buf_id_tab_var_name])
            end,
            desc = "Explorer (focus current file)",
          }
          for _, mode in ipairs { "n", "x", "o", "i" } do
            maps[mode][normalize_keymap "<D-e>"] = toggle_mini_files_rhs
          end

          if not opts.autocmds then opts.autocmds = {} end
          opts.autocmds.minifiles = {
            {
              event = "User",
              pattern = "MiniFilesBufferCreate",
              callback = function(args)
                local explorer_state_ok, explorer_state = pcall(minifiles.get_explorer_state)
                if explorer_state_ok and explorer_state == nil and vim.api.nvim_buf_is_valid(args.buf) then
                  vim.api.nvim_tabpage_set_var(0, prev_buf_id_tab_var_name, args.buf)
                end
              end,
            },
          }

          for _, mode in ipairs { "n", "x", "o", "i" } do
            maps[mode][chord_prefix .. "e"] = focus_current_mini_files_rhs
            maps[mode][chord_prefix .. "<D-e>"] = focus_current_mini_files_rhs
          end
        end,
      },
    },
    opts = function(_, opts)
      if opts.windows == nil then opts.windows = {} end
      opts.windows.preview = true

      local minifiles = require "mini.files"

      local show_dotfiles = true

      local filter_show = function() return true end

      local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        minifiles.refresh { content = { filter = new_filter } }
      end
      --
      -- Make new window and set it as target
      local open_split = function(direction)
        return function()
          local new_target_window
          vim.api.nvim_win_call(minifiles.get_explorer_state().target_window, function()
            vim.cmd(direction .. " split")
            new_target_window = vim.api.nvim_get_current_win()
          end)
          minifiles.set_target_window(new_target_window)
          local fs_entry = minifiles.get_fs_entry()
          local is_at_file = fs_entry ~= nil and fs_entry.fs_type == "file"
          if is_at_file then minifiles.go_in { close_on_file = true } end
        end
      end

      local go_in_plus = function()
        for _ = 1, vim.v.count1 do
          minifiles.go_in { close_on_file = true }
        end
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })

          local function set_split_keymaps(modifier)
            vim.keymap.set(
              { "n", "v", "i" },
              "<" .. modifier .. "-\\>",
              open_split "belowright horizontal",
              { buffer = buf_id, desc = "Horizontal Split" }
            )
            vim.keymap.set(
              { "n", "v", "i" },
              "<" .. modifier .. "-S-\\>",
              open_split "belowright vertical",
              { buffer = buf_id, desc = "Vertical Split" }
            )
          end

          set_split_keymaps "D"
          set_split_keymaps "C"
          vim.keymap.set("n", "<CR>", go_in_plus, { buffer = buf_id, desc = "Go in entry plus" })
          vim.keymap.set({ "n", "v", "i" }, "<C-s>", minifiles.synchronize, { buffer = buf_id, desc = "Synchronize" })
        end,
      })
    end,
  },
  {
    "noice.nvim",
    lazy = false,
    optional = true,
    opts_extend = { "routes" },
    opts = {
      -- cmdline = { enabled = false },
      -- messages = { enabled = false },
      lsp = {
        hover = { enabled = false, silent = true },
        progress = { enabled = false },
        signature = { enabled = true },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
            },
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "; after #%d+" },
              { find = "; before #%d+" },
              { find = "%d+ more lines" },
              { find = "%d+ fewer lines" },
              { find = "vim%.tbl_islist is deprecated" },
              { find = "vim%.lsp%.get_active_clients%(%) is deprecated" },
              { find = "'width' key must be a positive Integer" },
              { find = "Cursor position outside buffer" },
            },
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "notify",
            kind = "warn",
            any = {
              { find = "offset_encoding is required" },
              { find = "position_encoding param is required" },
              { find = "Cursor position outside buffer" },
            },
          },
          opts = { skip = true },
        },
        -- {
        --   filter = {
        --     event = "msg_show",
        --     kind = "lua_error",
        --     find = "share/nvim/runtime/lua/vim/lsp/semantic_tokens.lua",
        --   },
        --   view = "mini",
        -- },
        {
          filter = {
            event = "msg_show",
            kind = "search_count",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "lsp",
            kind = "progress",
            cond = function(message)
              local client = vim.tbl_get(message.opts, "progress", "client")
              return (client == "lua_ls" and message:content():find "Diagnosing")
                or (client == "null-ls" and message:content():find "diagnostics")
            end,
          },
          opts = { skip = true },
        },
      },
    },
  },
  {
    "nvim-colorizer.lua",
    optional = true,
    opts = {
      filetypes = {
        "*",
        "!noice",
      },
    },
  },
  {
    "nvim-highlight-colors",
    optional = true,
    opts = {
      enable_tailwind = true,
    },
  },
  {
    "toggleterm.nvim",
    optional = true,
    opts = function(_, opts)
      local on_create = opts.on_create or function() end
      opts.on_create = function(term)
        on_create(term)
        if term.hidden then
          local function toggle() term:toggle() end
          local toggle_modes = { "n", "t", "i" }
          local toggle_opts = { desc = "Toggle terminal", buffer = term.bufnr }
          vim.keymap.set(toggle_modes, "<C-S-'>", toggle, toggle_opts)
          vim.keymap.set(toggle_modes, '<C-">', toggle, toggle_opts)
        end
      end
    end,
    specs = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)
          local autocmds = opts.autocmds or {}
          local terminal = require "util.terminal"
          local astrocore = require "astrocore"
          local use_kitty_for_terminal_splits = false

          local is_kitty = terminal.is_kitty()
          if is_kitty and use_kitty_for_terminal_splits then
            local toggle_terminal_horizontal_split_rhs = {
              terminal.toggle_terminal,
              desc = "Toggle terminal",
            }
            local toggle_terminal_vertical_split_rhs = {
              function() terminal.toggle_terminal { direction = "vertical" } end,
              desc = "Toggle terminal (vertical split)",
            }
            for _, mode in ipairs { "n", "i" } do
              maps[mode]["<C-'>"] = toggle_terminal_horizontal_split_rhs
              maps[mode]["<F7>"] = toggle_terminal_horizontal_split_rhs
              maps[mode]["<C-S-'>"] = toggle_terminal_vertical_split_rhs
              maps[mode]['<C-">'] = toggle_terminal_vertical_split_rhs
            end
          end

          ---@param existing_normal_mode_mapping string The existing normal mode mapping to be used for resizing
          local function term_resize(existing_normal_mode_mapping)
            return function()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), "n", false)
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes(existing_normal_mode_mapping, true, false, true),
                "m",
                false
              )
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", false)
            end
          end

          maps.t["<M-PageUp>"] = { term_resize "<M-PageUp>", desc = "Resize split up" }
          maps.t["<M-PageDown>"] = { term_resize "<M-PageDown>", desc = "Resize split down" }
          maps.t["<M-Home>"] = { term_resize "<M-Home>", desc = "Resize split left" }
          maps.t["<M-End>"] = { term_resize "<M-End>", desc = "Resize split right" }
          maps.t["<M-Left>"] = { "<M-b>", desc = "Go to previous word" }
          maps.t["<M-Right>"] = { "<M-f>", desc = "Go to next word" }
          maps.t[normalize_keymap "<D-Esc>"] = { [[<C-\><C-n>]], desc = "Switch to normal mode" }

          local toggle_term_rhs = { "<Cmd>ToggleTerm<CR>", desc = "Toggle terminal" }
          maps.t['<C-">'] = toggle_term_rhs
          maps.t["<C-S-'>"] = toggle_term_rhs

          ---@param key string The keybinding to toggle the terminal
          ---@param exec_name string The name of the executable to be mapped
          local function add_terminal_program_mapping(key, exec_name)
            if vim.fn.executable(exec_name) == 1 then
              maps.n[key] = {
                function() astrocore.toggle_term_cmd { cmd = exec_name, direction = "float" } end,
                desc = "ToggleTerm " .. exec_name,
                noremap = false,
              }
            end
          end

          local prefix = "<Leader>t"
          add_terminal_program_mapping(prefix .. "t", "btop")
          add_terminal_program_mapping(prefix .. "y", "yazi")
          if vim.fn.executable "git" == 1 and vim.fn.executable "lazygit" == 1 then
            autocmds.lazygit_theme_toggle = {
              {
                event = { "VimEnter", "ColorScheme" },
                callback = function() vim.env.LG_CONFIG_FILE = terminal.get_lazygit_config_file() end,
              },
            }
            maps.n["<Leader>gh"] = {
              function()
                local path = vim.fn.expand "%:p"
                astrocore.toggle_term_cmd { cmd = "lazygit --filter " .. path, direction = "float" }
              end,
              desc = "Git commits (current file lazygit)",
            }
            maps.n["<Leader>pg"] = {
              function()
                local config_path = vim.fn.stdpath "config"
                astrocore.toggle_term_cmd { cmd = "lazygit --path " .. config_path, direction = "float" }
              end,
              desc = "Open lazygit (AstroNvim config)",
            }
          end
        end,
      },
      {
        "flatten.nvim",
        version = "*",
        optional = true,
        opts = function(_, opts)
          ---@type Terminal?
          local saved_terminal
          opts.callbacks = {
            should_block = function(argv)
              -- Note that argv contains all the parts of the CLI command, including
              -- Neovim's path, commands, options and files.
              -- See: :help v:argv

              -- In this case, we would block if we find the `-b` flag
              -- This allows you to use `nvim -b file1` instead of
              -- `nvim --cmd 'let g:flatten_wait=1' file1`
              return vim.tbl_contains(argv, "-b")

              -- Alternatively, we can block if we find the diff-mode option
              -- return vim.tbl_contains(argv, "-d")
            end,
            pre_open = function()
              local term = require "toggleterm.terminal"
              local termid = term.get_focused_id()
              saved_terminal = term.get(termid, true)
            end,
            post_open = function(bufnr, winnr, ft, is_blocking)
              if is_blocking and saved_terminal then
                -- Hide the terminal while it's blocking
                saved_terminal:close()
              else
                -- If it's a normal file, just switch to its window
                vim.api.nvim_set_current_win(winnr)

                -- If we're in a different wezterm pane/tab, switch to the current one
                -- Requires willothy/wezterm.nvim
                -- require("wezterm").switch_pane.id(tonumber(os.getenv "WEZTERM_PANE"))
              end

              -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
              -- If you just want the toggleable terminal integration, ignore this bit
              if ft == "gitcommit" or ft == "gitrebase" then
                vim.api.nvim_create_autocmd("BufWritePost", {
                  buffer = bufnr,
                  once = true,
                  callback = vim.schedule_wrap(function() vim.api.nvim_buf_delete(bufnr, {}) end),
                })
              end
            end,
            block_end = function()
              -- After blocking ends (for a git commit, etc), reopen the terminal
              vim.schedule(function()
                if saved_terminal then
                  saved_terminal:open()
                  saved_terminal = nil
                end
              end)
            end,
          }
        end,
        init = function() vim.env.VISUAL = "nvim -b" end,
      },
    },
  },
  {
    "AstroNvim/astrocore",
    dependencies = {
      {
        "catppuccin",
        optional = true,
        opts = {
          term_colors = true,
        },
      },
    },
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      local terminal = require "util.terminal"
      local autocmds = opts.autocmds or {}

      --- Parse a string of hex characters as a color.
      ---
      --- The string can contain 1 to 4 hex characters. The returned value is
      --- between 0.0 and 1.0 (inclusive) representing the intensity of the color.
      ---
      --- For instance, if only a single hex char "a" is used, then this function
      --- returns 0.625 (10 / 16), while a value of "aa" would return 0.664 (170 /
      --- 256).
      ---
      --- @param c string Color as a string of hex chars
      --- @return number? Intensity of the color
      local function parsecolor(c)
        if #c == 0 or #c > 4 then return nil end

        local val = tonumber(c, 16)
        if not val then return nil end

        local max = tonumber(string.rep("f", #c), 16)
        return val / max
      end

      --- Parse an OSC 11 response
      ---
      --- Either of the two formats below are accepted:
      ---
      ---   OSC 11 ; rgb:<red>/<green>/<blue>
      ---
      --- or
      ---
      ---   OSC 11 ; rgba:<red>/<green>/<blue>/<alpha>
      ---
      --- where
      ---
      ---   <red>, <green>, <blue>, <alpha> := h | hh | hhh | hhhh
      ---
      --- The alpha component is ignored, if present.
      ---
      --- @param resp string OSC 11 response
      --- @return string? Red component
      --- @return string? Green component
      --- @return string? Blue component
      local function parseosc11(resp)
        local r, g, b
        r, g, b = resp:match "^\027%]11;rgb:(%x+)/(%x+)/(%x+)$"
        if not r and not g and not b then
          local a
          r, g, b, a = resp:match "^\027%]11;rgba:(%x+)/(%x+)/(%x+)/(%x+)$"
          if not a or #a > 4 then return nil, nil, nil end
        end

        if r and g and b and #r <= 4 and #g <= 4 and #b <= 4 then return r, g, b end

        return nil, nil, nil
      end
      autocmds.background_temrinal_toggle = {
        {
          event = "TermResponse",
          desc = "Update the value of 'background' automatically based on the terminal emulator's background color",
          nested = true,
          callback = function(args)
            -- This logic already exists in nvim-0.11, but it runs only if the background option wasn't set manually.
            -- We want to run it unconditionally, so we check if the background option was set manually to not run it twice.
            if vim.fn.has "nvim-0.11" == 1 and not vim.api.nvim_get_option_info2("background", {}).was_set then
              return
            end
            local sequence = type(args.data) == "string" and args.data or args.data.sequence ---@type string
            local r, g, b = parseosc11(sequence)
            if r and g and b then
              local rr = parsecolor(r)
              local gg = parsecolor(g)
              local bb = parsecolor(b)

              if rr and gg and bb then
                local luminance = (0.299 * rr) + (0.587 * gg) + (0.114 * bb)
                local bg = luminance < 0.5 and "dark" or "light"
                vim.go.background = bg
              end
            end
          end,
        },
      }
      if not terminal.is_kitty() then return end
      local initial_kitty_colors = nil
      local current_nvim_terminal_colors = {}
      local initial_colors_name = vim.g.colors_name
      local initial_background = vim.go.background

      --- Converts a decimal color value to a hexadecimal color string.
      ---@param d number? The decimal color value.
      local function get_hex_color_from_decimal(d)
        if d == nil then return nil end
        return string.format("#%06X", d)
      end

      local function get_nvim_terminal_colors()
        local terminal_colors = {}
        for i = 0, 15 do
          local color_name = "terminal_color_" .. i
          local color_value = vim.g[color_name]
          if color_value ~= nil then terminal_colors[color_name] = color_value end
        end
        return terminal_colors
      end

      local function set_kitty_colors()
        local colors_table = {}
        local cursor_highlight = vim.api.nvim_get_hl(0, { name = "Cursor" })
        local cursor_text_color = get_hex_color_from_decimal(cursor_highlight.fg)
        if cursor_text_color ~= nil then table.insert(colors_table, "cursor_text_color=" .. cursor_text_color) end
        local normal_highlight = vim.api.nvim_get_hl(0, { name = "Normal" })
        local background_color = get_hex_color_from_decimal(normal_highlight.bg)
        if background_color ~= nil then table.insert(colors_table, "background=" .. background_color) end
        -- Setting terminal colors in Kitty will also update the colors for Neovim terminal instances that are already running
        for i = 0, 15 do
          local color_name = "terminal_color_" .. i
          vim.g[color_name] = nil
          local color_value = current_nvim_terminal_colors[color_name]
          if color_value ~= nil then
            local value = "color" .. i .. "=" .. color_value
            table.insert(colors_table, value)
          end
        end
        terminal.kitty_set_colors(colors_table):wait()
      end

      opts.options.opt.guicursor =
        "n-v-c-sm:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr-o:hor20-Cursor/lCursor"
      if vim.fn.has "nvim-0.11" == 1 then
        opts.options.opt.guicursor = opts.options.opt.guicursor .. ",t:block-blinkon500-blinkoff500-TermCursor"
      end
      autocmds.kitty_colors_toggle = {
        {
          event = "VimEnter",
          desc = "Set initial Kitty colors on VimEnter",
          callback = function()
            initial_kitty_colors = terminal.kitty_get_all_colors_list()
            current_nvim_terminal_colors = get_nvim_terminal_colors()
            set_kitty_colors()
          end,
        },
        {
          event = { "ColorScheme" },
          desc = "Update terminal colors table on colorscheme change",
          callback = function() current_nvim_terminal_colors = get_nvim_terminal_colors() end,
        },
        {
          event = { "VimResume", "ColorScheme" },
          desc = "Toggle Kitty colors in Neovim",
          callback = set_kitty_colors,
        },
        {
          event = { "VimLeavePre", "VimSuspend" },
          desc = "Reset Kitty to default when exiting or suspending Neovim",
          callback = function()
            if
              initial_kitty_colors == nil
              or (initial_colors_name == vim.g.colors_name and initial_background == vim.go.background)
            then
              return
            end
            terminal.kitty_set_colors(initial_kitty_colors):wait()
          end,
        },
      }
    end,
  },
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaRead", "SudaWrite" },
    lazy = false,
    init = function()
      vim.g["suda#noninteractive"] = 1
      vim.g["suda_smart_edit"] = 1
    end,
  },
  {
    "nvim-notify",
    optional = true,
    config = function(_, opts)
      require("notify").setup(opts)

      local banned_messages = { "position_encoding param is required" }

      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(msg, ...)
        if type(msg) == "string" then
          for _, banned in ipairs(banned_messages) do
            if msg:find(banned, 0, true) then return end
          end
        end
        require "notify"(msg, ...)
      end
    end,
  },
  {
    "overseer.nvim",
    optional = false,
    opts = function(_, opts)
      opts.strategy = { "terminal" }
      local config = require "overseer.config"
      local updated_default_alias = config.component_aliases.default
      table.insert(updated_default_alias, { "open_output", on_start = "never", on_complete = "failure" })
      if not opts.component_aliases then opts.component_aliases = {} end
      opts.component_aliases.default = updated_default_alias
      opts.component_aliases.default_neotest = {
        "on_output_summarize",
        "on_exit_set_status",
        "on_complete_notify",
        "on_complete_dispose",
      }
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(
        vim.tbl_filter(function(server) return server ~= "emmet_ls" end, opts.ensure_installed),
        { "emmet_language_server" }
      )
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
      luasnip.filetype_extend("typescript", { "typescriptreact" })
      require("luasnip.loaders.from_vscode").lazy_load {
        paths = { vim.fn.stdpath "config" .. "/snippets" },
      }
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
