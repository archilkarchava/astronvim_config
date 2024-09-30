-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize None-ls

---@type LazySpec
return {
  {
    "mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      if not opts.handlers then opts.handlers = {} end

      opts.handlers.prettierd = function(source_name, methods)
        local null_ls = require "null-ls"
        for _, method in ipairs(methods) do
          null_ls.register(null_ls.builtins[method][source_name].with {
            filetypes = {
              "javascript",
              "javascriptreact",
              "typescript",
              "typescriptreact",
              "json",
              "jsonc",
              "yaml",
            },
          })
        end
      end
    end,
  },
}
