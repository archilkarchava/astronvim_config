---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@param opts AstroLSPOpts
    opts = function(_, opts)
      if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
      opts.mappings.n["<leader>lR"] = {
        function()
          require("telescope.builtin").lsp_references {
            trim_text = true,
            show_line = false,
          }
        end,
      }
    end,
  },
}
