---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
      local maps = assert(opts.mappings)
      local git_command = { "git", "log", "--pretty=format:%<|(10)%h %<(100,trunc)%s [%ar] [%an]\n", "--date=short" }
      local common_git_commits_options = {
        git_command = git_command,
        use_file_path = true,
        layout_strategy = "vertical",
        layout_config = {
          height = 0.99,
          width = 0.99,
          preview_cutoff = 0,
        },
      }
      maps.n["<Leader>gc"] = {
        function() require("telescope.builtin").git_commits(vim.tbl_extend("force", {}, common_git_commits_options)) end,
        desc = "Git commits (repository)",
      }
      maps.n["<Leader>gC"] = {
        function() require("telescope.builtin").git_bcommits(vim.tbl_extend("force", {}, common_git_commits_options)) end,
        desc = "Git commits (current file)",
      }
      if vim.fn.executable "rg" == 1 then
        maps.n["<Leader>fW"] = {
          function()
            require("telescope.builtin").live_grep {
              additional_args = { "--hidden", "--no-ignore" },
            }
          end,
          desc = "Find words in all files",
        }
      end
    end,
  },
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
              height = 0.99,
              width = 0.99,
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
    branch = "master",
    opts = function(_, opts)
      local actions = require "telescope.actions"
      local layout_actions = require "telescope.actions.layout"
      for _, mode in ipairs { "n", "i" } do
        opts.defaults.mappings[mode]["<PageDown>"] = actions.cycle_history_next
        opts.defaults.mappings[mode]["<PageUp>"] = actions.cycle_history_prev
        opts.defaults.mappings[mode]["<C-y>"] = layout_actions.toggle_preview
      end
    end,
  },
}
