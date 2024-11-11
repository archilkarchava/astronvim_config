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

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@param opts AstroCoreOpts
  opts = function(_, opts)
    local astrocore = require "astrocore"
    local terminal = require "util.terminal"
    local platform = require "util.platform"
    local maps = assert(opts.mappings)
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
    local is_kitty = terminal.is_kitty()
    if is_kitty then
      for _, mode in ipairs { "n", "i" } do
        maps[mode]["<C-'>"] = {
          function()
            local is_term_window_exists = false
            if vim.g.kitty_toggle_term_window_id ~= nil then
              local find_term_window_result =
                vim.system({ "kitty", "@", "ls", "--match", "id:" .. vim.g.kitty_toggle_term_window_id }):wait()
              is_term_window_exists = find_term_window_result.code == 0
            end
            if is_term_window_exists then
              vim.system { "kitty", "@", "focus-window", "--match", "id:" .. vim.g.kitty_toggle_term_window_id }
            else
              local create_term_window_result = vim
                .system({
                  "kitty",
                  "@",
                  "launch",
                  "--location=hsplit",
                  "--cwd=current",
                  "--bias=30",
                }, { text = true })
                :wait()
              local window_id = tostring(create_term_window_result.stdout)
              if create_term_window_result.code ~= 0 or not window_id then return end
              vim.g.kitty_toggle_term_window_id = window_id
            end
            vim.system { "kitty", "@", "goto-layout", "splits" }
          end,
          desc = "Toggle terminal",
        }
      end
    end

    if vim.fn.executable "git" == 1 and vim.fn.executable "lazygit" == 1 then
      maps.n["<leader>gh"] = {
        function()
          local path = vim.fn.expand "%:p"
          astrocore.toggle_term_cmd { cmd = "lazygit --filter " .. path, direction = "float" }
        end,
        desc = "Git commits (current file lazygit)",
      }
      maps.n["<leader>pg"] = {
        function()
          local config_path = vim.fn.stdpath "config"
          astrocore.toggle_term_cmd { cmd = "lazygit --path " .. config_path, direction = "float" }
        end,
        desc = "Open lazygit (AstroNvim config)",
      }
    end

    if vim.fn.executable "btop" == 1 then
      maps.n["<Leader>tt"] =
        { function() astrocore.toggle_term_cmd { cmd = "btop", direction = "float" } end, desc = "ToggleTerm btop" }
    end

    remap_key_if_exists(maps, "<C-PageUp>", "<C-Up>")
    remap_key_if_exists(maps, "<C-PageDown>", "<C-Down>")
    remap_key_if_exists(maps, "<C-Home>", "<C-Left>")
    remap_key_if_exists(maps, "<C-End>", "<C-Right>")

    ---@type AstroCoreOpts
    local modified_opts = {
      -- Configure core features of AstroNvim
      features = {
        large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
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
        __env = {
          {
            pattern = ".env.*",
            event = { "BufRead", "BufNewFile" },
            callback = function(args) vim.diagnostic.enable(false, { bufnr = args.buf }) end,
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
          ["<leader>W"] = { "<cmd>noautocmd w<cr>", desc = "Save without running auto-commands" },

          -- navigate buffer tabs
          ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

          -- mappings seen under group name "Buffer"
          ["<Leader>bd"] = {
            function()
              require("astroui.status.heirline").buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Close buffer from tabline",
          },
          ["<leader>lc"] = {
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
        pattern = {
          [".env.*"] = "sh",
        },
      },
    }
    return astrocore.extend_tbl(opts, modified_opts)
  end,
}
