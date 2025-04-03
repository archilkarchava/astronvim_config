-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

local picker_utils = require "util.picker"

---@type LazySpec
local plugin_specs = {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.recipes.neovide" },
  { import = "astrocommunity.recipes.auto-session-restore" },
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder

  { import = "astrocommunity.code-runner.overseer-nvim" },
  { import = "astrocommunity.color.nvim-highlight-colors" },
  -- { import = "astrocommunity.colorscheme.vscode-nvim" },
  -- { import = "astrocommunity.colorscheme.github-nvim-theme" },
  { import = "astrocommunity.colorscheme.catppuccin" },

  { import = "astrocommunity.debugging.nvim-chainsaw" },
  { import = "astrocommunity.debugging.nvim-dap-virtual-text" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.game.leetcode-nvim" },
  { import = "astrocommunity.git.diffview-nvim" },
  { import = "astrocommunity.git.neogit" },
  { import = "astrocommunity.file-explorer.mini-files" },
  -- { import = "astrocommunity.file-explorer.oil-nvim" },
  -- { import = "astrocommunity.file-explorer.telescope-file-browser-nvim" },
  { import = "astrocommunity.git.octo-nvim" },
  { import = "astrocommunity.lsp.garbage-day-nvim" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.astro" },
  { import = "astrocommunity.pack.svelte" },
  -- { import = "astrocommunity.pack.vue" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.sql" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.zig" },
  { import = "astrocommunity.docker.lazydocker" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  -- { import = "astrocommunity.markdown-and-latex.markview-nvim" },
  -- { import = "astrocommunity.scrolling.neoscroll-nvim" },
  { import = "astrocommunity.search.grug-far-nvim" },
  -- { import = "astrocommunity.completion.avante-nvim" },
  { import = "astrocommunity.completion.cmp-cmdline" },
  { import = "astrocommunity.completion.copilot-lua" },
  -- { import = "astrocommunity.completion.magazine-nvim" },
  { import = "astrocommunity.completion.blink-cmp" },
  { import = "astrocommunity.test.neotest" },
  { import = "astrocommunity.test.nvim-coverage" },
  { import = "astrocommunity.motion.harpoon" },
  -- { import = "astrocommunity.motion.flash-nvim" },
  -- { import = "astrocommunity.motion.leap-nvim" },
  { import = "astrocommunity.motion.flit-nvim" },
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.motion.mini-ai" },
  { import = "astrocommunity.motion.mini-bracketed" },
  { import = "astrocommunity.motion.mini-move" },
  -- { import = "astrocommunity.motion.vim-matchup" },
  { import = "astrocommunity.quickfix.nvim-bqf" },
  { import = "astrocommunity.terminal-integration.flatten-nvim" },
  { import = "astrocommunity.editing-support.copilotchat-nvim" },
  { import = "astrocommunity.editing-support.mini-splitjoin" },
  { import = "astrocommunity.editing-support.dial-nvim" },
  { import = "astrocommunity.editing-support.undotree" },
  { import = "astrocommunity.editing-support.telescope-undo-nvim" },
  { import = "astrocommunity.editing-support.nvim-treesitter-context" },
  { import = "astrocommunity.utility.lua-json5" },
  { import = "astrocommunity.utility.noice-nvim" },
}

if type(plugin_specs) == "string" then return plugin_specs end

local snacks_picker_spec = { import = "astrocommunity.fuzzy-finder.snacks-picker" }
local fzf_picker_spec = { import = "astrocommunity.fuzzy-finder.fzf-lua" }

if picker_utils.picker == "snacks" then
  table.insert(plugin_specs, snacks_picker_spec)
elseif picker_utils.picker == "fzf" then
  table.insert(plugin_specs, fzf_picker_spec)
end

return plugin_specs
