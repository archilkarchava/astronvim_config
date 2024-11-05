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
        maps.n["<Leader>fs"] = {
          function() require("util.telescope").grep_last_search() end,
          desc = "Find last search pattern",
        }
        maps.v["<Leader>fc"] =
          { function() require("telescope.builtin").grep_string() end, desc = "Find selected word" }
      end
    end,
  },
  {
    "AstroNvim/astrolsp",
    ---@param opts AstroLSPOpts
    opts = function(_, opts)
      local utils = require "astrocore"
      if utils.is_available "nvim-bqf" then return end
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
        opts.defaults.mappings[mode]["<C-o>"] = actions.toggle_all
        opts.defaults.mappings[mode]["<C-y>"] = layout_actions.toggle_preview
      end
    end,
  },
  {
    "jvgrootveld/telescope-zoxide",
    lazy = true,
    specs = {
      {
        "nvim-telescope/telescope.nvim",
        config = function(_, opts)
          require("telescope").setup(opts)
          require("telescope").load_extension "zoxide"
        end,
        dependencies = {
          "jvgrootveld/telescope-zoxide",
          {
            "AstroNvim/astrocore",
            ---@param opts AstroCoreOpts
            opts = function(_, opts)
              if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
              local maps = assert(opts.mappings)
              local is_windows = require("util.platform").is_windows()
              local zo_data_dir = vim.fn.stdpath "data" .. "/zoxide"
              local zo_data_dir_var_name = "_ZO_DATA_DIR"
              maps.n["<Leader>fZ"] = { "<Cmd>Telescope zoxide list<CR>", desc = "Find directories" }
              maps.n["<Leader>fz"] = {
                function()
                  local cmd_shell = "cmd.exe"
                  local shell = is_windows and cmd_shell or (vim.o.shell or "sh")
                  local shell_arg = "-c"
                  local is_cmd_shell = shell == cmd_shell
                  if is_cmd_shell then shell_arg = "/C /V" end
                  local list_command = "zoxide query -ls"
                  local zoxide_cmd = is_cmd_shell
                      and "set " .. zo_data_dir_var_name .. "=" .. zo_data_dir .. "&& " .. list_command
                    or zo_data_dir_var_name .. "=" .. zo_data_dir .. " " .. list_command
                  local prompt_title = "[ Projects List ]"
                  require("telescope").extensions.zoxide.list {
                    cmd = {
                      shell,
                      shell_arg,
                      zoxide_cmd,
                    },
                    prompt_title = prompt_title,
                  }
                end,
                desc = "Find projects",
              }
              ---@param dir string
              local function zoxide_add(dir)
                return vim.system({ "zoxide", "add", dir }, { env = { [zo_data_dir_var_name] = zo_data_dir } })
              end
              if not opts.autocmds then opts.autocmds = {} end
              local autocmds = assert(opts.autocmds)
              autocmds.zoxide = {
                {
                  event = "DirChanged",
                  pattern = "*",
                  callback = function()
                    if vim.v.event.changed_window then return end
                    zoxide_add(vim.v.event.cwd)
                  end,
                  desc = "Update the list of projects in the zoxide database",
                },
                {
                  event = "VimEnter",
                  callback = function()
                    if vim.fn.argc() > 0 then return end
                    zoxide_add(vim.fn.getcwd())
                  end,
                  desc = "Update the list of projects in the zoxide database",
                },
              }
            end,
          },
        },
      },
    },
  },
}
