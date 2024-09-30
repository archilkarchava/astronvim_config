-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local is_macos = vim.uv.os_uname().sysname == "Darwin"

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@papam opts AstroCoreOpts
  opts = function(_, opts)
    local astrocore = require "astrocore"
    local maps = assert(opts.mappings)
    --- Check if the OS is macOS
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
          sidescrolloff = 6,
          exrc = true,
        },
        g = { -- vim.g.<key>
          -- configure global vim variables (vim.g)
          -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
          -- This can be found in the `lua/lazy_setup.lua` file
          matchup_matchparen_pumvisible = 1,
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
          ["<C-c>"] = { "ciw", desc = "Change inner word" },
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
        filename = { -- (((
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
        }, -- )))
      },
    }
    return astrocore.extend_tbl(opts, modified_opts)
  end,
}
