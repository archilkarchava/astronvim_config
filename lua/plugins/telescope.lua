---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@param opts AstroLSPOpts
    opts = function(_, opts)
      if opts.mappings.n.gd then
        opts.mappings.n.gd[1] = function() require("telescope.builtin").lsp_definitions { reuse_win = true } end
      end
      if opts.mappings.n.gI then
        opts.mappings.n.gI[1] = function() require("telescope.builtin").lsp_implementations { reuse_win = true } end
      end
      if opts.mappings.n.gy then
        opts.mappings.n.gy[1] = function() require("telescope.builtin").lsp_type_definitions { reuse_win = true } end
      end
      if opts.mappings.n["<Leader>lG"] then
        opts.mappings.n["<Leader>lG"][1] = function()
          vim.ui.input({ prompt = "Symbol Query: (leave empty for word under cursor)" }, function(query)
            if query then
              -- word under cursor if given query is empty
              if query == "" then query = vim.fn.expand "<cword>" end
              require("telescope.builtin").lsp_workspace_symbols {
                query = query,
                prompt_title = ("Find word (%s)"):format(query),
              }
            end
          end)
        end
      end
      if opts.mappings.n["<Leader>lR"] then
        opts.mappings.n["<Leader>lR"][1] = function()
          require("telescope.builtin").lsp_references {
            trim_text = false,
            show_line = true,
            fname_width = 70,
            layout_strategy = "vertical",
            path_display = {
              shorten = 2,
            },
            layout_config = {
              height = 0.95,
              preview_cutoff = 0,
            },
          }
        end
      end
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = function(_, opts)
      local utils = require "astrocore"
      local actions = require "telescope.actions"
      return utils.extend_tbl(opts, {
        defaults = {
          mappings = {
            n = {
              ["<PageDown>"] = actions.cycle_history_next,
              ["<PageUp>"] = actions.cycle_history_prev,
            },
            i = {
              ["<PageDown>"] = actions.cycle_history_next,
              ["<PageUp>"] = actions.cycle_history_prev,
            },
          },
        },
      })
    end,
  },
}
