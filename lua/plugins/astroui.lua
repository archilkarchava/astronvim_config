-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = vim.g.vscode and "default" or "catppuccin",
    lazygit = false,
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    -- highlights = {
    --   init = { -- this table overrides highlights in all themes
    --     -- Normal = { bg = "#000000" },
    --   },
    --   astrodark = { -- a table of overrides/changes when applying the astrotheme theme
    --     -- Normal = { bg = "#000000" },
    --   },
    -- },
    -- -- Icons can be configured throughout the interface
    -- icons = {
    --   -- configure the loading of the lsp in the status line
    --   LSPLoading1 = "⠋",
    --   LSPLoading2 = "⠙",
    --   LSPLoading3 = "⠹",
    --   LSPLoading4 = "⠸",
    --   LSPLoading5 = "⠼",
    --   LSPLoading6 = "⠴",
    --   LSPLoading7 = "⠦",
    --   LSPLoading8 = "⠧",
    --   LSPLoading9 = "⠇",
    --   LSPLoading10 = "⠏",
    -- },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        local autocmds = opts.autocmds or {}
        local terminal = require "util.terminal"
        if not terminal.is_kitty() then return end
        local function toggle_kitty_theme()
          local is_dark_theme = vim.o.background == "dark"
          if is_dark_theme then
            terminal.kitty_set_colors "dark"
          else
            terminal.kitty_set_colors "light"
          end
        end
        autocmds.kitty_theme_toggle = {
          {
            event = { "VimLeavePre", "VimSuspend" },
            callback = function() terminal.kitty_set_colors "default" end,
          },
          {
            event = { "ColorScheme", "VimResume", "VimEnter" },
            callback = toggle_kitty_theme,
          },
        }
      end,
    },
  },
}
