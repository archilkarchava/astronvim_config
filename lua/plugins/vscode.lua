if not vim.g.vscode then return {} end

return {
  {
    "mini.splitjoin",
    optional = true,
    cond = true,
  },
  {
    "echasnovski/mini.bracketed",
    cond = true,
    optional = true,
    opts = {
      buffer = { suffix = "" },
      conflict = { suffix = "" },
      diagnostic = { suffix = "" },
      file = { suffix = "" },
      oldfile = { suffix = "" },
      quickfix = { suffix = "" },
      undo = { suffix = "" },
      window = { suffix = "" },
    },
    keys = {
      {
        "<M-O>",
        function() pcall(require("mini.bracketed").jump, "backward", { wrap = false }) end,
        mode = "n",
        desc = "Jump backward inside the current buffer",
      },
      {
        "<M-I>",
        function() pcall(require("mini.bracketed").jump, "forward", { wrap = false }) end,
        mode = "n",
        desc = "Jump forward inside the current buffer",
      },
    },
  },
  {
    "nvim-surround",
    optional = true,
    specs = {
      {
        "AstroNvim/astroui",
        ---@type AstroUIOpts
        opts = {
          highlights = {
            init = {
              NvimSurroundHighlight = { link = "IncSearch" },
              FakeVisual = { bg = "#45475b" },
            },
          },
        },
      },
    },
  },
  { "nvim-treesitter/nvim-treesitter", opts = { highlight = { enable = true } } },
}
