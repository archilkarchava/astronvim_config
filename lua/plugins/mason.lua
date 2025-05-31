-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason
---@type LazySpec
return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "rust_analyzer",
        "graphql",
        "stylelint_lsp",
      })
    end,
  },
}
--
-- ---@type LazySpec
-- return {
--   -- use mason-tool-installer for automatically installing Mason packages
--   {
--     "WhoIsSethDaniel/mason-tool-installer.nvim",
--     -- overrides `require("mason-tool-installer").setup(...)`
--     opts = {
--       -- Make sure to use the names found in `:Mason`
--       ensure_installed = {
--         -- install language servers
--         "lua-language-server",
--
--         -- install formatters
--         "stylua",
--
--         -- install debuggers
--         "debugpy",
--
--         -- install any other package
--         "tree-sitter-cli",
--       },
--     },
--   },
-- }
