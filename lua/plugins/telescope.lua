local picker_utils = require "util.picker"

---@type LazySpec
return {
  {
    "nvim-telescope/telescope.nvim",
    enabled = true,
    branch = "master",
    opts = function(_, opts)
      local actions = require "telescope.actions"
      local layout_actions = require "telescope.actions.layout"
      for _, mode in ipairs { "n", "i" } do
        opts.defaults.mappings[mode]["<PageDown>"] = actions.cycle_history_next
        opts.defaults.mappings[mode]["<PageUp>"] = actions.cycle_history_prev
        opts.defaults.mappings[mode]["<C-o>"] = actions.toggle_all
        opts.defaults.mappings[mode]["<C-y>"] = layout_actions.toggle_preview
        opts.defaults.mappings[mode]["<C-\\>"] = actions.select_horizontal
        opts.defaults.mappings[mode]["<C-S-\\>"] = actions.select_vertical
      end
    end,
    specs = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local picker = picker_utils.get_picker()
          if picker == "snacks" then return end
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)
          local git_command =
            { "git", "log", "--pretty=format:%<|(10)%h %<(100,trunc)%s [%ar] [%an]\n", "--date=short" }
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
            function()
              require("telescope.builtin").git_commits(vim.tbl_extend("force", {}, common_git_commits_options))
            end,
            desc = "Git commits (repository)",
          }
          maps.n["<Leader>gC"] = {
            function()
              require("telescope.builtin").git_bcommits(vim.tbl_extend("force", {}, common_git_commits_options))
            end,
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
              function() picker_utils.grep_last_search() end,
              desc = "Find last search pattern",
            }
            if maps.n["<Leader>f"] then maps.v["<Leader>f"] = { desc = maps.n["<Leader>f"].desc } end
            maps.v["<Leader>fc"] =
              { function() require("telescope.builtin").grep_string() end, desc = "Find selected word" }
          end

          for _, mode in ipairs { "n", "v", "s", "x", "o", "i", "l", "c", "t" } do
            maps[mode]["<D-p>"] = { function() require("telescope.builtin").find_files() end, desc = "Find files" }
            maps[mode]["<D-P>"] = { function() require("telescope.builtin").commands() end, desc = "Find commands" }
          end

          for _, mode in ipairs { "n", "v", "i" } do
            maps[mode]["<M-S-Tab>"] = {
              function()
                require("telescope.builtin").buffers {
                  sort_lastused = true,
                  sort_mru = true,
                  ignore_current_buffer = true,
                }
              end,
              desc = "Find buffers (last used)",
            }
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
    },
  },
  {
    "jvgrootveld/telescope-zoxide",
    enabled = not require("util.picker").get_picker() == "telescope",
    lazy = true,
    specs = {
      {
        "nvim-telescope/telescope.nvim",
        opts = function(_, opts)
          local astrocore = require "astrocore"
          local neogit_mapping = astrocore.is_available "neogit"
              and {
                action = function(selection) vim.cmd.Neogit("cwd=" .. selection.path) end,
                after_action = function(selection)
                  if vim.bo.filetype == "NeogitStatus" then vim.notify("Neogit opened for " .. selection.path) end
                end,
              }
            or nil
          local function cd_action(selection)
            if vim.fn.getcwd() == selection.path then
              vim.notify("Already in " .. selection.path)
              return false
            end
            local dir_changed, err = pcall(vim.cmd.cd, selection.path)
            if not dir_changed then
              vim.notify("Error while changing directory: " .. err, vim.log.levels.ERROR)
              return false
            end
            return true
          end
          local function notify_dir_changed(selection) vim.notify("Directory changed to " .. selection.path) end

          return astrocore.extend_tbl(opts, {
            extensions = {
              zoxide = {
                mappings = {
                  ["<CR>"] = {
                    action = function(selection)
                      local dir_changed = cd_action(selection)
                      if not dir_changed then return end
                      local ok, resession = pcall(require, "resession")
                      if not ok then return end
                      resession.load(vim.fn.getcwd(), { dir = "dirsession" })
                      vim.cmd.LspRestart()
                      notify_dir_changed(selection)
                    end,
                  },
                  ["<C-CR>"] = {
                    action = function(selection)
                      local dir_changed = cd_action(selection)
                      if not dir_changed then return end
                      notify_dir_changed(selection)
                    end,
                  },
                  ["<C-g>"] = neogit_mapping,
                },
              },
            },
          })
        end,
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
              local prefix = "<Leader>f"
              local is_windows = require("util.platform").is_windows()
              local zoxide = require "util.zoxide"
              local telescope = require "telescope"
              local action_state = require "telescope.actions.state"
              local function remove_path(prompt_bufnr)
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                current_picker:delete_selection(function(selection)
                  local remove_cmd_res = zoxide.remove(selection.path):wait()
                  return remove_cmd_res.code == 0
                end)
              end
              local function attach_mappings(_, map)
                map({ "i", "n" }, "<M-d>", remove_path)
                return true
              end
              --- Generate the zoxide list command based on options
              ---@param include_cwd boolean? Whether to include the current working directory in the list
              local function get_list_command(include_cwd)
                local base_cmd = "zoxide query --list --score"
                if include_cwd then return base_cmd end
                return base_cmd .. " | grep -v " .. vim.fn.getcwd() .. "$"
              end
              maps.n[prefix .. "Z"] = {
                function()
                  telescope.extensions.zoxide.list {
                    attach_mappings = attach_mappings,
                  }
                end,
                desc = "Find directories",
              }
              maps.n[prefix .. "z"] = {
                function()
                  local cmd_shell = "cmd.exe"
                  local shell = is_windows and cmd_shell or (vim.o.shell or "sh")
                  local shell_arg = "-c"
                  local is_cmd_shell = shell == cmd_shell
                  if is_cmd_shell then shell_arg = "/C /V" end
                  local list_command = get_list_command()
                  local zoxide_cmd = is_cmd_shell
                      and "set " .. zoxide.DATA_DIR_VAR_NAME .. "=" .. zoxide.DATA_DIR .. "&& " .. list_command
                    or zoxide.DATA_DIR_VAR_NAME .. "=" .. zoxide.DATA_DIR .. " " .. list_command
                  local prompt_title = "[ Projects List ]"
                  telescope.extensions.zoxide.list {
                    cmd = {
                      shell,
                      shell_arg,
                      zoxide_cmd,
                    },
                    prompt_title = prompt_title,
                    attach_mappings = attach_mappings,
                  }
                end,
                desc = "Find projects",
              }
              if not opts.autocmds then opts.autocmds = {} end
              local autocmds = assert(opts.autocmds)
              autocmds.zoxide = {
                {
                  event = "DirChanged",
                  pattern = "*",
                  callback = function()
                    if vim.v.event.changed_window then return end
                    zoxide.add(vim.v.event.cwd)
                  end,
                  desc = "Update the list of projects in the zoxide database",
                },
                {
                  event = "VimEnter",
                  callback = function()
                    if vim.fn.argc() > 0 then return end
                    zoxide.add(vim.fn.getcwd())
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
