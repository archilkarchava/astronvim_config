-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@param mappings AstroCoreMappings A table containing the key mappings for different modes
---@param new_lhs string The new keymap to be assigned
---@param orig_lhs string The original keymap to be remapped
---@param modes table<number, string>? A list of modes in which the remapping should occur
---@param opts AstroCoreMapping? Additional options for the remapping, such as description
local function remap_key_if_exists(mappings, new_lhs, orig_lhs, modes, opts)
  modes = modes or { "", "n", "v", "x", "s", "o", "!", "i", "l", "c", "t" }
  opts = opts or {}
  for _, mode in ipairs(modes) do
    if mappings[mode][orig_lhs] ~= nil then
      local desc = opts.desc or type(mappings[mode][orig_lhs]) == "table" and mappings[mode][orig_lhs].desc or nil
      local keymap_opts = vim.tbl_extend("force", opts or {}, { orig_lhs, remap = true, desc = desc })
      mappings[mode][new_lhs] = keymap_opts
    end
  end
end

---@param bool boolean
local function bool2str(bool) return bool and "on" or "off" end

---@param enabled boolean
local function notify_bufline_auto_sort_state(enabled)
  return require("astrocore").notify(("buffer line sorting %s"):format(bool2str(enabled)))
end

local dotenv_ft = "dotenv"
local is_bufline_auto_sort_enabled = false

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@param opts AstroCoreOpts
  opts = function(_, opts)
    local astrocore = require "astrocore"
    local patch_func = astrocore.patch_func
    vim.g.ignored_messages = vim.g.ignored_messages or {}
    _G.print = patch_func(_G.print, function(orig, ...)
      local args = { ... }
      for _, arg in ipairs(args) do
        for _, msg in ipairs(vim.g.ignored_messages) do
          if type(arg) == "string" and arg:find(msg) then return end
        end
      end
      return orig(...)
    end)
    local platform = require "util.platform"
    if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
    local maps = assert(opts.mappings)
    opts.commands = opts.commands or {}
    local commands = assert(opts.commands)
    local is_macos = platform.is_macos()
    if is_macos then
      for _, mode in ipairs { "n", "x", "o", "i" } do
        maps[mode]["<D-z>"] = {
          "<cmd>undo<cr>",
          desc = "Undo",
        }
        maps[mode]["<D-Z>"] = {
          "<cmd>redo<cr>",
          desc = "Redo",
        }
      end
    end

    for _, mode in ipairs { "n", "x" } do
      maps[mode]["x"] = { '"_x' }
      maps[mode]["X"] = { '"_X' }
      maps[mode]["<C-d>"] = { "<C-d>zz" }
      maps[mode]["<C-u>"] = { "<C-u>zz" }
    end
    for _, mode in ipairs { "v", "s", "x", "o", "i", "l", "c", "t" } do
      maps[mode]["<C-c>"] = { "<C-c>", noremap = true }
    end
    maps.n["<C-c>"] = { "ciw", desc = "Change inner word", noremap = true }

    remap_key_if_exists(maps, "<M-PageUp>", "<C-Up>")
    remap_key_if_exists(maps, "<M-PageDown>", "<C-Down>")
    remap_key_if_exists(maps, "<M-Home>", "<C-Left>")
    remap_key_if_exists(maps, "<M-End>", "<C-Right>")

    ---@param enabled boolean
    local function switch_bufline_auto_sort_state(enabled)
      is_bufline_auto_sort_enabled = enabled
      notify_bufline_auto_sort_state(is_bufline_auto_sort_enabled)
    end

    commands.BuflineAutoSortEnable = {
      function() switch_bufline_auto_sort_state(true) end,
      desc = "Enable automatic buffer line sorting",
    }
    commands.BuflineAutoSortDisable = {
      function() switch_bufline_auto_sort_state(false) end,
      desc = "Disable automatic buffer line sorting",
    }
    commands.BuflineAutoSortToggle = {
      function() switch_bufline_auto_sort_state(not is_bufline_auto_sort_enabled) end,
      desc = "Toggle automatic buffer line sorting",
    }

    commands.CopyPath = {
      function()
        local path = vim.fn.expand "%:p"
        vim.fn.setreg("+", path)
        vim.notify('Copied "' .. path .. '" to the clipboard.')
      end,
      desc = "Copy the absolute path of the current buffer to the clipboard",
    }

    commands.CopyRelPath = {
      function()
        local path = vim.fn.expand "%:~:."
        vim.fn.setreg("+", path)
        vim.notify('Copied "' .. path .. '" to the clipboard.')
      end,
      desc = "Copy the relative path of the current buffer to the clipboard",
    }

    maps.n["<Leader>uB"] = {
      "<cmd>ToggleBuflineAutoSort<cr>",
      desc = "Toggle automatic buffer line sorting",
    }

    -- navigate buffer tabs
    local navigate_to_next_buffer_rhs =
      { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" }
    local navigate_to_prev_buffer_rhs =
      { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" }

    -- move buffer tabs
    local move_buffer_tab_left_rhs = {
      function() require("astrocore.buffer").move(-vim.v.count1) end,
      desc = "Move buffer tab left",
    }
    local move_buffer_tab_right_rhs = {
      function() require("astrocore.buffer").move(vim.v.count1) end,
      desc = "Move buffer tab right",
    }
    maps.n.H = navigate_to_prev_buffer_rhs
    maps.n.L = navigate_to_next_buffer_rhs
    for _, mode in ipairs { "n", "v", "s", "x", "i", "t" } do
      maps[mode]["<M-S-[>"] = navigate_to_prev_buffer_rhs
      maps[mode]["<M-S-]>"] = navigate_to_next_buffer_rhs
      maps[mode]["<C-S-PageUp>"] = move_buffer_tab_left_rhs
      maps[mode]["<C-S-PageDown>"] = move_buffer_tab_right_rhs

      -- Revert changes
      maps[mode]["<D-k><D-R>"] = { "<cmd>edit!<cr>", desc = "Revert buffer" }
    end

    local modified_opts = {
      -- Configure core features of AstroNvim
      features = {
        large_buf = {
          notify = not vim.g.vscode,
        }, -- set global limits for large files for disabling features like treesitter
        autopairs = true, -- enable autopairs at start
        cmp = true, -- enable completion at start
        diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
        highlighturl = true, -- highlight URLs at start
        notifications = true, -- enable notifications at start
      },
      -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
      diagnostics = {
        virtual_text = true,
        underline = true,
      },
      autocmds = {
        bufline_auto_sort = {
          {
            event = "BufAdd",
            desc = "Automatically sort buffer lines by buffer number",
            callback = function()
              if not is_bufline_auto_sort_enabled then return end
              vim.schedule(function() require("astrocore.buffer").sort "bufnr" end)
            end,
          },
        },
      },
      sessions = {
        ignore = {
          dirs = { "/tmp/shell-edit" },
        },
      },
      on_keys = {
        -- auto_hlsearch autocmd provided by AstroNvim does not work well with multicursor.nvim
        auto_hlsearch = {
          function(char)
            if vim.fn.mode() == "n" then
              local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
              ---@diagnostic disable-next-line: undefined-field
              if vim.opt.hlsearch:get() ~= new_hlsearch then vim.cmd "nohlsearch" end
            end
          end,
        },
      },
      -- vim options can be configured here
      options = {
        opt = { -- vim.opt.<key>
          relativenumber = true, -- sets vim.opt.relativenumber
          number = true, -- sets vim.opt.number
          spell = false, -- sets vim.opt.spell
          signcolumn = "yes", -- sets vim.opt.signcolumn to yes
          wrap = false, -- sets vim.opt.wrap
          scrolloff = 6,
          cmdheight = vim.g.vscode and 1 or 0,
          sidescrolloff = 6,
          exrc = not vim.g.vscode,
          timeoutlen = 1000,
        },
        g = { -- vim.g.<key>
          -- configure global vim variables (vim.g)
          -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
          -- This can be found in the `lua/lazy_setup.lua` file
        },
      },
      -- Mappings can be configured through AstroCore as well.
      -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
      mappings = {
        -- first key is the mode
        n = {
          ["<M-Tab>"] = { "<C-^>" },
          ["<M-c>"] = { "<cmd>tabclose<cr>" },
          ["<Leader>W"] = { "<cmd>noautocmd w<cr>", desc = "Save without running auto-commands" },
          -- mappings seen under group name "Buffer"
          ["<Leader>bd"] = {
            function()
              require("astroui.status.heirline").buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Close buffer from tabline",
          },
          ["<Leader>lc"] = {
            "<cmd>LspRestart<cr>",
            desc = "Restart (garbage Collect) LSP clients",
          },

          -- tables with just a `desc` key will be registered with which-key if it's installed
          -- this is useful for naming menus
          -- ["<Leader>b"] = { desc = "Buffers" },

          -- setting a mapping to false will disable it
          -- ["<C-S>"] = false,
        },
      },
      filetypes = {
        filename = {
          [".codespellrc"] = "confini",
          [".dace.conf"] = "yaml",
          [".envrc"] = "sh",
          ["/etc/environment"] = "confini",
          ["/etc/mkinitcpio.conf"] = "confini",
          ["compose.yml"] = "yaml.docker-compose",
          ["compose.yaml"] = "yaml.docker-compose",
          -- ["docker-compose.yml"] = "yaml.docker-compose",
          -- ["docker-compose.yaml"] = "yaml.docker-compose",
          ["dvc.lock"] = "yaml",
          ["Dvcfile"] = "yaml",
          ["devcontainer.json"] = "jsonc",
          ["launch.json"] = "jsonc",
          ["settings.json"] = "jsonc",
          ["tasks.json"] = "jsonc",
          ["spack.lock"] = "json",
          ["zuliprc"] = "confini",
        },
        -- Change the filetype for .env files to disable shellcheck diagnostics
        pattern = {
          [".env%.?.*"] = dotenv_ft,
        },
      },
    } --[[@as AstroCoreOpts]]

    -- if vim.fn.has "nvim-0.11" == 1 then
    --   -- Disable "Hit ENTER to continue" messages
    --   modified_opts.options.opt.messagesopt = "wait:1000,history:500"
    -- end

    -- Enable syntax highlighting for .env files with treesitter
    vim.treesitter.language.register("bash", dotenv_ft)
    return astrocore.extend_tbl(opts, modified_opts)
  end,
}
