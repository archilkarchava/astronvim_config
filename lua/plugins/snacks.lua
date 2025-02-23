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
      if astrocore.is_available(garbage_day_plugin_name) then
        astrocore.on_load(garbage_day_plugin_name, function()
          local garbage_day_utils = require "garbage-day.utils"
          garbage_day_utils.stop_lsp()
          garbage_day_utils.start_lsp()
          vim.defer_fn(function() vim.cmd.edit() end, 400)
        end)
      end
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
  {
    "snacks.nvim",
    priority = 10000,
    lazy = false,
    specs = {
      { "nvim-notify", enabled = false },
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = opts.mappings

          local find_notifications = {
            function() require("snacks").picker.notifications() end,
            desc = "Find notifications",
          }
          local show_notification_history =
            { function() require("snacks").notifier.show_history() end, desc = "Notification history" }
          maps.n["<Leader>fn"] = picker_utils.picker == "snacks" and find_notifications or show_notification_history
          if picker_utils.picker == "snacks" then maps.n["<Leader>fN"] = show_notification_history end
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
  },
}

---@type LazySpec
local snacks_picker_spec = {
  "snacks.nvim",
  opts = {
    picker = {
      sources = {
        zoxide = { confirm = load_session },
        projects = { confirm = load_session, dev = { "~/projects/sandbox", vim.env.ECOM_WORK_DIR, "~/projects/insta" } },
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
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
        local maps = opts.mappings

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
}

if type(plugin_specs) == "string" then return plugin_specs end

if picker_utils.picker == "snacks" then table.insert(plugin_specs, snacks_picker_spec) end

return plugin_specs
