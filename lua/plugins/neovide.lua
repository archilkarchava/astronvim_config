if not vim.g.neovide then
  return {} -- do nothing if not in a Neovide session
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@param opts AstroCoreOpts
  opts = function(_, opts)
    local astrocore = require "astrocore"
    local maps = assert(opts.mappings)
    for _, mode in ipairs { "n", "v", "s", "x", "o", "i", "l", "c", "t" } do
      maps[mode]["<D-v>"] = {
        function() vim.api.nvim_paste(vim.fn.getreg "+", true, -1) end,
        desc = "Paste from system clipboard",
        silent = true,
      }
      maps["n"]["<D-c>"] = {
        '"+yy',
        desc = "Copy line to clipboard",
        silent = true,
      }
      maps["v"]["<D-c>"] = {
        '"+ygv',
        desc = "Copy to clipboard",
        silent = true,
      }
    end
    ---@type AstroCoreOpts
    local modified_opts = {
      mappings = maps,
      options = {
        opt = {
          guifont = "BerkeleyMono Nerd Font:h15",
          termguicolors = true,
          linespace = 0,
        },
        g = {
          neovide_input_macos_option_key_is_meta = "only_left",
          neovide_scale_factor = 1.0,
          neovide_padding_top = 0,
          neovide_padding_bottom = 0,
          neovide_padding_right = 0,
          neovide_padding_left = 0,
        },
      },
    }
    return astrocore.extend_tbl(opts, modified_opts)
  end,
}
