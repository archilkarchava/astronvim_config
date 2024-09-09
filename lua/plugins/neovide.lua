if not vim.g.neovide then
  return {} -- do nothing if not in a Neovide session
end

vim.g.neovide_input_macos_option_key_is_meta = "only_left"

local function paste() vim.api.nvim_paste(vim.fn.getreg "+", true, -1) end
vim.keymap.set({ "n", "v", "s", "x", "o", "i", "l", "c", "t" }, "<D-v>", paste, { noremap = true, silent = true })
vim.opt.termguicolors = true

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = { -- configure vim.opt options
        -- configure font
        guifont = "BerkeleyMono Nerd Font:h15",
        termguicolors = true,
        -- line spacing
        linespace = 0,
      },
      g = { -- configure vim.g variables
        -- configure scaling
        neovide_scale_factor = 1.0,
        -- configure padding
        neovide_padding_top = 0,
        neovide_padding_bottom = 0,
        neovide_padding_right = 0,
        neovide_padding_left = 0,
      },
    },
  },
}
