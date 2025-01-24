-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

local function notify_dir_changed(dir) vim.notify("Directory changed to " .. dir) end

local function load_session(picker)
  picker:close()
  local item = picker:current()
  if not item then return end
  local dir = item.file
  local session_loaded = false
  local ok, resession = pcall(require, "resession")
  if not ok then
    vim.fn.chdir(dir)
    return
  end
  local function cb()
    session_loaded = true
    vim.schedule(function()
      vim.cmd.LspRestart()
      notify_dir_changed(dir)
      resession.remove_hook("post_load", cb)
    end)
  end
  resession.add_hook("post_load", cb)
  vim.defer_fn(function()
    if not session_loaded then Snacks.picker.files() end
  end, 100)
  vim.fn.chdir(dir)
  resession.load(dir, { dir = "dirsession", silence_errors = true })
end

---@type LazySpec
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    specs = {
      {
        "lazydev.nvim",
        optional = true,
        opts = {
          library = {
            { path = "snacks.nvim", words = { "Snacks" } },
          },
        },
      },
      {
        "mini.files",
        optional = true,
        init = function()
          vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesActionRename",
            callback = function(event) Snacks.rename.on_rename_file(event.data.from, event.data.to) end,
          })
        end,
      },
    },
    opts = {
      bigfile = { enabled = false },
      notifier = { enabled = false },
      quickfile = { enabled = true },
      statuscolumn = { enabled = false },
      words = { enabled = false },
      scroll = {
        enabled = false,
        filter = function(buf)
          return vim.g.snacks_scroll ~= false
            and vim.b[buf].snacks_scroll ~= false
            and vim.bo[buf].buftype ~= "terminal"
            and vim.bo[buf].filetype ~= "Avante"
        end,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...) Snacks.debug.inspect(...) end
          _G.bt = function() Snacks.debug.backtrace() end
          vim.print = _G.dd -- Override print to use snacks for `:=` command
        end,
      })
    end,
  },
  -- Picker
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      picker = {
        ui_select = true,
        win = {
          input = {
            keys = {
              ["<PageUp>"] = { "history_back", mode = { "i", "n" } },
              ["<PageDown>"] = { "history_forward", mode = { "i", "n" } },
            },
          },
        },
      },
    },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>f"] = vim.tbl_get(opts, "_map_sections", "f")
          if vim.fn.executable "git" == 1 then
            maps.n["<Leader>g"] = vim.tbl_get(opts, "_map_sections", "g")
            maps.n["<Leader>gb"] = { function() require("snacks").picker.git_branches() end, desc = "Git branches" }
            maps.n["<Leader>gc"] = {
              function() require("snacks").picker.git_log() end,
              desc = "Git commits (repository)",
            }
            maps.n["<Leader>gC"] = {
              function() require("snacks").picker.git_log { current_file = true, follow = true } end,
              desc = "Git commits (current file)",
            }
            maps.n["<Leader>gt"] = { function() require("snacks").picker.git_status() end, desc = "Git status" }
          end
          maps.n["<Leader>f<CR>"] =
            { function() require("snacks").picker.resume() end, desc = "Resume previous search" }
          maps.n["<Leader>f'"] = { function() require("snacks").picker.marks() end, desc = "Find marks" }
          maps.n["<Leader>fl"] = {
            function() require("snacks").picker.lines() end,
            desc = "Find lines",
          }
          maps.n["<Leader>fa"] = {
            function() require("snacks").picker.files { cwd = vim.fn.stdpath "config", desc = "Config Files" } end,
            desc = "Find AstroNvim config files",
          }
          maps.n["<Leader>fb"] = { function() require("snacks").picker.buffers() end, desc = "Find buffers" }
          maps.n["<Leader>fc"] =
            { function() require("snacks").picker.grep_word() end, desc = "Find word under cursor" }
          maps.n["<Leader>fC"] = { function() require("snacks").picker.commands() end, desc = "Find commands" }
          maps.n["<Leader>ff"] = {
            function()
              require("snacks").picker.files {
                hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
              }
            end,
            desc = "Find files",
          }
          maps.n["<Leader>fF"] = {
            function() require("snacks").picker.files { hidden = true, ignored = true } end,
            desc = "Find all files",
          }
          maps.n["<Leader>fg"] = { function() require("snacks").picker.git_files() end, desc = "Find git files" }
          maps.n["<Leader>fh"] = { function() require("snacks").picker.help() end, desc = "Find help" }
          maps.n["<Leader>fk"] = { function() require("snacks").picker.keymaps() end, desc = "Find keymaps" }
          maps.n["<Leader>fm"] = { function() require("snacks").picker.man() end, desc = "Find man" }
          maps.n["<Leader>fo"] = { function() require("snacks").picker.recent() end, desc = "Find old files" }
          maps.n["<Leader>fO"] =
            { function() require("snacks").picker.recent { cwd = vim.fn.getcwd() } end, desc = "Find old files (cwd)" }
          maps.n["<Leader>fp"] =
            { function() require("snacks").picker.projects { confirm = load_session } end, desc = "Find projects" }
          maps.n["<Leader>fz"] =
            { function() require("snacks").picker.zoxide { confirm = load_session } end, desc = "Find zoxide projects" }

          maps.n["<Leader>fr"] = { function() require("snacks").picker.registers() end, desc = "Find registers" }
          maps.n["<Leader>fs"] = { function() require("snacks").picker.smart() end, desc = "Find buffers/recent/files" }
          maps.n["<Leader>ft"] = { function() require("snacks").picker.colorschemes() end, desc = "Find themes" }
          if vim.fn.executable "rg" == 1 then
            maps.n["<Leader>fw"] = { function() require("snacks").picker.grep() end, desc = "Find words" }
            maps.n["<Leader>fW"] = {
              function() require("snacks").picker.grep { hidden = true, ignored = true } end,
              desc = "Find words in all files",
            }
          end
          maps.n["<Leader>lD"] = { function() require("snacks").picker.diagnostics() end, desc = "Search diagnostics" }
          maps.n["<Leader>ls"] = { function() require("snacks").picker.lsp_symbols() end, desc = "Search symbols" }

          for _, mode in ipairs { "n", "v", "s", "x", "o", "i", "l", "c", "t" } do
            maps[mode]["<D-p>"] = { function() require("snacks").picker.smart() end, desc = "Find files" }
            maps[mode]["<D-P>"] = { function() require("snacks").picker.commands() end, desc = "Find commands" }
          end

          for _, mode in ipairs { "n", "v", "s", "x", "o", "i", "l", "c", "t" } do
            maps[mode]["<M-S-Tab>"] = {
              function() require("snacks").picker.buffers { current = false } end,
              desc = "Find buffers (last used)",
            }
          end
        end,
      },
      {
        "folke/todo-comments.nvim",
        optional = true,
        dependencies = { "folke/snacks.nvim" },
        specs = {
          {
            "AstroNvim/astrocore",
            opts = {
              mappings = {
                n = {
                  ["<Leader>fT"] = {
                    function()
                      if not package.loaded["todo-comments"] then -- make sure to load todo-comments
                        require("lazy").load { plugins = { "todo-comments.nvim" } }
                      end
                      require("snacks").picker.todo_comments()
                    end,
                    desc = "Todo Comments",
                  },
                },
              },
            },
          },
        },
      },
      {
        "nvim-neo-tree/neo-tree.nvim",
        optional = true,
        opts = {
          commands = {
            find_in_dir = function(state)
              local node = state.tree:get_node()
              local path = node.type == "file" and node:get_parent_id() or node:get_id()
              require("snacks").picker.files { cwd = path }
            end,
          },
          window = { mappings = { F = "find_in_dir" } },
        },
      },
      {
        "stevearc/dressing.nvim",
        optional = true,
        opts = { select = { enabled = false } },
      },
      {
        "nvim-autopairs",
        optional = true,
        opts_extend = { "disable_filetype" },
        opts = {
          disable_filetype = { "snacks_picker_input" },
        },
      },
    },
  },
}
