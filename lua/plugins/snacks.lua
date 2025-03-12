-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

local picker_utils = require "util.picker"
local astrocore = require "astrocore"
local garbage_day_plugin_name = "garbage-day.nvim"

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
      notify_dir_changed(dir)
      resession.remove_hook("post_load", cb)
    end)
    if astrocore.is_available(garbage_day_plugin_name) then
      astrocore.on_load(garbage_day_plugin_name, function()
        local garbage_day_utils = require "garbage-day.utils"
        garbage_day_utils.stop_lsp()
        vim.defer_fn(function() vim.cmd.edit() end, 100)
        vim.defer_fn(function() garbage_day_utils.start_lsp() end, 700)
      end)
    end
  end
  resession.add_hook("post_load", cb)
  vim.defer_fn(function()
    if not session_loaded then Snacks.picker.files() end
  end, 100)
  vim.fn.chdir(dir)
  resession.load(dir, { dir = "dirsession", silence_errors = true })
end

---@type LazySpec
local plugin_specs = {
  {
    "folke/snacks.nvim",
    priority = 10000,
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
      -- Replaced with AstroLsp's file operations
      --[[ {
        "mini.files",
        optional = true,
        dependencies = {
          {
            "AstroNvim/astrocore",
            ---@type AstroCoreOpts
            opts = {
              autocmds = {
                mini_files_rename = {
                  {
                    event = "User",
                    pattern = "MiniFilesActionRename",
                    callback = function(event) Snacks.rename.on_rename_file(event.data.from, event.data.to) end,
                  },
                },
              },
            },
          },
        },
      }, ]]
    },
    opts = {
      quickfile = { enabled = true },
      statuscolumn = { enabled = false },
      image = {},
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
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = {
          autocmds = {
            debugging_globals = {
              {
                event = "User",
                pattern = "VeryLazy",
                callback = function()
                  -- Setup some globals for debugging (lazy-loaded)
                  _G.dd = function(...) Snacks.debug.inspect(...) end
                  _G.bt = function() Snacks.debug.backtrace() end
                  -- vim.print = _G.dd -- Override print to use snacks for `:=` command
                end,
              },
            },
          },
        },
      },
    },
  },
  {
    "snacks.nvim",
    optional = true,
    opts = {
      styles = {
        {
          keys = {
            term_normal = {
              "<Esc>",
              function(self) return require("util.terminal").double_escape(self) end,
              mode = "t",
              desc = "Double escape to normal mode",
            },
          },
        },
      },
    },
  },
  {
    "snacks.nvim",
    optional = true,
    specs = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = { features = { large_buf = false } },
      },
    },
    opts = {
      bigfile = {
        notify = not vim.g.vscode,
        size = 1.5 * 1024 * 1024,
        line_length = 1000,
      },
    },
  },
  {
    "snacks.nvim",
    priority = 10000,
    lazy = false,
    specs = {
      { "nvim-notify", enabled = false },
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)

          local find_notifications = {
            function() Snacks.picker.notifications() end,
            desc = "Find notifications",
          }
          local show_notification_history =
            { function() Snacks.notifier.show_history() end, desc = "Notification history" }
          maps.n["<Leader>fn"] = picker_utils.picker == "snacks" and find_notifications or show_notification_history
          if picker_utils.picker == "snacks" then maps.n["<Leader>fN"] = show_notification_history end
          maps.n["<Leader>uD"] = { function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" }
        end,
      },
    },
    opts = {
      notifier = {},
      picker = {
        sources = {
          notifications = { confirm = "focus_preview" },
        },
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      local patch_func = astrocore.patch_func
      Snacks.notifier.notify = patch_func(Snacks.notifier.notify, function(orig, msg, level, o)
        local notif_id = orig(msg, level, o)
        local title = o and o.title or ""
        if
          not (title == "AstroNvim" and msg == "Notifications off") and not astrocore.config.features.notifications
        then
          Snacks.notifier.hide(notif_id)
        end
      end)
    end,
  },
}

---@type LazySpec
local snacks_picker_spec = {
  {
    "snacks.nvim",
    opts = {
      picker = {
        sources = {
          zoxide = { confirm = load_session },
          projects = {
            confirm = load_session,
            dev = { "~/projects/sandbox", vim.env.ECOM_WORK_DIR, "~/projects/insta" },
          },
          explorer = {
            layout = { layout = { position = "right" } },
          },
        },
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
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)

          maps.n["<Leader>fp"] = { function() require("snacks").picker.projects() end, desc = "Find projects" }
          maps.n["<Leader>fu"] = { function() require("snacks").picker.undo() end, desc = "Undotree (Snacks)" }
          maps.n["<Leader>fz"] = { function() require("snacks").picker.zoxide() end, desc = "Find zoxide projects" }
          maps.n["<Leader>fe"] = { function() require("snacks").explorer() end, desc = "Explorer (Snacks)" }

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
        "nvim-autopairs",
        optional = true,
        opts_extend = { "disable_filetype" },
        opts = {
          disable_filetype = { "snacks_picker_input" },
        },
      },
    },
  },
  {
    "harpoon",
    optional = true,
    specs = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)
          local harpoon = require "harpoon"
          -- picker
          local function generate_harpoon_picker()
            local file_paths = {}
            for _, item in ipairs(harpoon:list().items) do
              table.insert(file_paths, {
                text = item.value,
                file = item.value,
              })
            end
            return file_paths
          end
          local prefix = "<Leader><Leader>"
          maps.n[prefix .. "m"] = {
            function()
              Snacks.picker {
                finder = generate_harpoon_picker,
                win = {
                  input = {
                    keys = {
                      ["<C-x>"] = { "harpoon_delete", mode = { "n", "i" } },
                    },
                  },
                  list = {
                    keys = {
                      ["<C-x>"] = { "harpoon_delete", mode = { "n", "i" } },
                    },
                  },
                },
                actions = {
                  harpoon_delete = function(picker, item)
                    local to_remove = item or picker:selected()
                    table.remove(harpoon:list().items, to_remove.idx)
                    picker:find {
                      refresh = true, -- refresh picker after removing values
                    }
                  end,
                },
              }
            end,
            desc = "Show marks in Snacks picker",
          }
        end,
      },
    },
  },
}

if type(plugin_specs) == "string" then return plugin_specs end

if picker_utils.picker == "snacks" then table.insert(plugin_specs, snacks_picker_spec) end

return plugin_specs
