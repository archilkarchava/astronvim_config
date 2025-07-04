-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

local util_keymaps = require "util.keymaps"
local normalize_keymap = util_keymaps.normalize_keymap

---@alias SuggestionsProvider "supermaven" | "copilot" | "none"

local suggestion_providers = {
  copilot = "copilot",
  supermaven = "supermaven",
  none = "none",
}

local is_windows = require("util.platform").is_windows()

---@type SuggestionsProvider
local default_suggestions_provider = suggestion_providers.supermaven

---@type SuggestionsProvider
vim.g.current_suggestions_provider = default_suggestions_provider

local function supermaven_cond_toggle()
  if vim.g.current_suggestions_provider == suggestion_providers.none then return end
  local ok_api, api = pcall(require, "supermaven-nvim.api")
  local ok_config, config = pcall(require, "supermaven-nvim.config")
  if not ok_api or not ok_config then return end
  if config.condition() then
    if api.is_running() then
      api.stop()
      return
    end
  else
    if api.is_running() then return end
    api.start()
  end
end

local supermaven_helpers = {
  is_running = function()
    local ok, api = pcall(require, "supermaven-nvim.api")
    if not ok then return end
    return api.is_running()
  end,
  disable = function()
    local ok, api = pcall(require, "supermaven-nvim.api")
    if not ok then return end
    if api.is_running() then api.stop() end
  end,
  enable = function()
    local ok, api = pcall(require, "supermaven-nvim.api")
    if not ok then return end
    if not api.is_running() then api.start() end
  end,
  restart = function()
    local ok, api = pcall(require, "supermaven-nvim.api")
    if not ok then return end
    api.restart()
  end,
  toggle = function()
    local ok, api = pcall(require, "supermaven-nvim.api")
    if not ok then return end
    api.toggle()
  end,
}

local function is_copilot_running()
  local ok, copilot_client = pcall(require, "copilot.client")
  if not ok then return false end
  return not copilot_client.is_disabled()
end

local copilot_helpers = {
  is_running = is_copilot_running,
  disable = function()
    local ok, copilot_command = pcall(require, "copilot.command")
    if not ok then return end
    copilot_command.disable()
  end,
  enable = function()
    local ok, copilot_command = pcall(require, "copilot.command")
    if not ok then return end
    copilot_command.enable()
  end,
  restart = function()
    local ok, copilot_command = pcall(require, "copilot.command")
    if not ok then return end
    copilot_command.disable()
    copilot_command.enable()
  end,
  toggle = function()
    local ok, copilot_command = pcall(require, "copilot.command")
    if not ok then return end
    if is_copilot_running() then
      copilot_command.disable()
    else
      copilot_command.enable()
    end
  end,
}

local function accept_suggestion()
  if copilot_helpers.is_running() then
    require("copilot.suggestion").accept()
  else
    require("supermaven-nvim.completion_preview").on_accept_suggestion()
  end
end

local function accept_word()
  if copilot_helpers.is_running() then
    require("copilot.suggestion").accept_word()
  else
    require("supermaven-nvim.completion_preview").on_accept_suggestion_word()
  end
end

local function clear_suggestion()
  if copilot_helpers.is_running() then
    require("copilot.suggestion").dismiss()
  else
    require("supermaven-nvim.completion_preview").on_dispose_inlay()
  end
end

local keymaps = {
  accept_suggestion = {
    lhs = { "<C-x>", "<D-S-right>" },
    rhs = accept_suggestion,
    desc = "Accept suggestion",
    noremap = true,
    silent = true,
  },
  accept_word = {
    lhs = { "<C-z>", "<D-right>" },
    rhs = accept_word,
    desc = "Accept word",
    noremap = true,
    silent = true,
  },
  clear_suggestion = {
    lhs = { "<C-]>", "<M-Esc>" },
    rhs = clear_suggestion,
    desc = "Clear suggestion",
    noremap = true,
    silent = true,
  },
}

local function get_avante_file_selector_provider() return require("util.picker").picker end

---@type LazySpec
return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      logger = {
        print_log_level = vim.log.levels.ERROR,
      },
      suggestion = {
        keymap = {
          accept = false,
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = false,
        },
      },
    },
    config = function(_, opts)
      local ignored_messages = vim.g.ignored_messages
      table.insert(ignored_messages, "%[Copilot%] Offline")
      vim.g.ignored_messages = ignored_messages
      require("copilot").setup(opts)
      if default_suggestions_provider ~= suggestion_providers.copilot then copilot_helpers.disable() end
    end,
    specs = {
      {
        "noice.nvim",
        optional = true,
        opts = function(_, opts)
          opts.routes = opts.routes or {}
          vim.list_extend(opts.routes, {
            {
              filter = {
                event = "msg_show",
                find = "%[Copilot%] Offline",
              },
              opts = { skip = true },
            },
          })
        end,
      },
    },
  },
  {
    "supermaven-inc/supermaven-nvim",
    -- event = "User AstroFile",
    event = "VeryLazy",
    opts = function(_, opts)
      return {
        keymaps = {
          accept_suggestion = keymaps.accept_suggestion.lhs[1],
          accept_word = keymaps.accept_word.lhs[1],
          clear_suggestion = keymaps.clear_suggestion.lhs[1],
        },
        -- ignore_filetypes = { cpp = true },
        -- color = {
        --   suggestion_color = "#ffffff",
        --   cterm = 244,
        -- },
        disable_inline_completion = false, -- disables inline completion for use with cmp
        disable_keymaps = true, -- disables built in keymaps for more manual control
        condition = function()
          if copilot_helpers.is_running() or vim.g.current_suggestions_provider == suggestion_providers.none then
            return true
          end
          if type(opts.condition) == "function" then return opts.condition() end
          return false
        end,
      }
    end,
    dependencies = {
      {
        "AstroNvim/astroui",
        opts = {
          icons = {
            Copilot = "",
            Supermaven = "",
            Suggestions = "",
          },
        },
      },
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          for _, keymap in pairs(keymaps) do
            for _, lhs in ipairs(keymap.lhs) do
              maps.i[lhs] = {
                keymap.rhs,
                desc = keymap.desc,
                noremap = keymap.noremap,
                silent = keymap.silent,
              }
            end
          end

          local utils = require "astrocore"
          local prefix = "<Leader>i"

          maps.n[prefix] =
            { desc = require("astroui").get_icon("Suggestions", 1, true) .. "Inline suggestions provider" }
          maps.n[prefix .. "s"] = {
            function()
              copilot_helpers.disable()
              supermaven_helpers.restart()
              vim.g.current_suggestions_provider = suggestion_providers.supermaven
              vim.notify "Switched to Supermaven inline suggestions provider"
            end,
            desc = require("astroui").get_icon("Supermaven", 1, true) .. "Supermaven",
          }
          if utils.is_available "copilot.lua" then
            maps.n[prefix .. "c"] = {
              function()
                supermaven_helpers.disable()
                copilot_helpers.restart()
                vim.g.current_suggestions_provider = suggestion_providers.copilot
                vim.notify "Switched to Copilot inline suggestions provider"
              end,
              desc = require("astroui").get_icon("Copilot", 1, true) .. "Copilot",
            }
          end
          maps.n[prefix .. "d"] = {
            function()
              supermaven_helpers.disable()
              copilot_helpers.disable()
              vim.g.current_suggestions_provider = suggestion_providers.none
              vim.notify "Disabled inline suggestions"
            end,
            desc = "Disable all",
          }
          opts.autocmds.supermaven = {
            {
              event = "LspAttach",
              desc = "Stop Supermaven when Copilot is attached",
              callback = supermaven_cond_toggle,
            },
            {
              event = "LspDetach",
              desc = "Start Supermaven when Copilot is detached",
              callback = supermaven_cond_toggle,
            },
          }
        end,
      },
    },
    specs = {
      {
        "noice.nvim",
        optional = true,
        opts = function(_, opts)
          opts.routes = opts.routes or {}
          vim.list_extend(opts.routes, {
            {
              filter = {
                find = "File is too large to send to server. Skipping%.%.%.",
              },
              opts = { skip = true },
            },
          })
        end,
      },
    },
  },
  {
    "yetone/avante.nvim",
    version = "*",
    event = "User AstroFile",
    build = is_windows and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" or "make",
    opts = {
      provider = "gemini",
      cursor_applying_provider = nil,
      -- behaviour = {
      --   enable_cursor_planning_mode = true,
      -- },
      selector = {
        provider = get_avante_file_selector_provider(),
      },
      -- auto_suggestions_provider = "copilot",
      hints = {
        enabled = false,
      },
      behavior = {
        auto_suggestions = false,
      },
      mappings = {
        diff = {
          cursor = "cC",
        },
      },
      windows = {
        width = 45,
      },
      providers = {
        ---@type AvanteProvider
        copilot = {
          -- model = "claude-3.5-sonnet",
          -- model = "gpt-4o-2024-08-06",
        },
        ---@type AvanteSupportedProvider
        gemini = {
          model = "gemini-2.5-flash",
        },
        ---@type AvanteSupportedProvider
        ["openrouter-gemini-2.5-pro-exp-03-25:free"] = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          api_key_name = "OPENROUTER_API_KEY",
          model = "google/gemini-2.5-pro-exp-03-25:free",
        },
        ---@type AvanteSupportedProvider
        ["openrouter-gemini/gemma-3-27b-it:free"] = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          api_key_name = "OPENROUTER_API_KEY",
          model = "google/gemma-3-27b-it:free",
        },
        ---@type AvanteSupportedProvider
        ["openrouter-deepseek/deepseek-r1:free"] = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          api_key_name = "OPENROUTER_API_KEY",
          model = "deepseek/deepseek-r1:free",
        },
        ---@type AvanteSupportedProvider
        ["openrouter-deepseek/deepseek-chat-v3-0324:free"] = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          api_key_name = "OPENROUTER_API_KEY",
          model = "deepseek/deepseek-chat-v3-0324:free",
        },
      },
    },
    dependencies = {
      {
        "AstroNvim/astroui",
        opts = { icons = { Avante = "" } },
      },
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      { "nvim-tree/nvim-web-devicons", optional = true },
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)
          local prefix = "<Leader>a"

          for _, mode in ipairs { "n", "x" } do
            if maps[mode][prefix] == nil then
              maps[mode][prefix] = { desc = require("astroui").get_icon("Avante", 1, true) .. "Avante" }
            end
          end

          local function go_to_mode(mode)
            if vim.fn.mode() == mode then return end
            local cursor_pos = vim.fn.getcurpos()
            if mode == "n" then
              vim.cmd.stopinsert()
            elseif mode == "i" then
              vim.cmd.startinsert()
            elseif mode:match "[vV\x16]" then
              if vim.fn.mode() ~= "n" then go_to_mode "n" end
              vim.cmd "normal! gv"
            end
            vim.schedule(function() vim.fn.setpos(".", cursor_pos) end)
          end

          ---@param filetype string
          local function check_is_avante_filetype(filetype) return filetype:find "^Avante" ~= nil end

          local function check_is_avante_buffer()
            if check_is_avante_filetype(vim.bo.filetype) then return true end
            if vim.bo.buftype ~= "nofile" then return false end
            local cur_bufnr = vim.api.nvim_get_current_buf()
            local prev_buf_filetype = vim.fn.getbufvar(cur_bufnr - 1, "&filetype")
            if check_is_avante_filetype(prev_buf_filetype) then return true end
            local next_buf_filetype = vim.fn.getbufvar(cur_bufnr + 1, "&filetype")
            if check_is_avante_filetype(next_buf_filetype) then return true end
            return false
          end

          for _, mode in ipairs { "n", "v", "s", "x", "i" } do
            maps[mode]["<D-C-i>"] = {
              function()
                local prev_mode_buf_var_name = "avante_prev_mode"
                local is_avante_buffer = check_is_avante_buffer()
                local cur_mode = vim.fn.mode()
                if not is_avante_buffer then
                  vim.api.nvim_buf_set_var(0, prev_mode_buf_var_name, cur_mode)
                  -- Workaround to make Avante always start in insert mode
                  if cur_mode == "i" then go_to_mode "n" end
                end
                require("avante.api").toggle()

                if vim.b[prev_mode_buf_var_name] == nil or not is_avante_buffer then return end
                go_to_mode(vim.b[prev_mode_buf_var_name])
                if is_avante_buffer then vim.api.nvim_buf_del_var(0, prev_mode_buf_var_name) end
              end,
              desc = "avante: toggle",
            }
          end
        end,
      },
      --- The below dependencies are optional,
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        enabled = false,
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        "telescope.nvim",
        optional = true,
        opts = function(_, opts)
          if get_avante_file_selector_provider() ~= "telescope" then return end
          for _, mode in ipairs { "n", "i" } do
            local enter_action = opts.defaults.mappings[mode]["<CR>"]
            if not enter_action then return end
            opts.defaults.mappings[mode]["<CR>"] = function(...)
              local picker = require("telescope.actions.state").get_current_picker(...)
              if picker.prompt_title:find "%(Avante%) Add" then
                return require("telescope.actions").select_default(...)
              end
              return enter_action(...)
            end
          end
        end,
      },
    },
    specs = {
      { -- if copilot.lua is available, default to copilot provider
        "zbirenbaum/copilot.lua",
        optional = true,
        specs = {
          {
            "avante.nvim",
            opts = {
              provider = "copilot",
            },
          },
        },
      },
      {
        -- make sure `Avante` is added as a filetype
        "MeanderingProgrammer/render-markdown.nvim",
        optional = true,
        opts = function(_, opts)
          if not opts.file_types then opts.file_types = { "markdown" } end
          opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "Avante" })
        end,
      },
      {
        -- make sure `Avante` is added as a filetype
        "OXY2DEV/markview.nvim",
        optional = true,
        opts = function(_, opts)
          if not opts.preview then opts.preview = {} end
          if not opts.preview.filetypes then opts.preview.filetypes = { "markdown", "quarto", "rmd" } end
          opts.preview.filetypes = require("astrocore").list_insert_unique(opts.preview.filetypes, { "Avante" })
        end,
      },
      {
        "saghen/blink.cmp",
        optional = true,
        specs = {
          {
            "saghen/blink.compat",
            lazy = true,
            opts = function()
              -- monkeypatch cmp.ConfirmBehavior for Avante
              require("cmp").ConfirmBehavior = {
                Insert = "insert",
                Replace = "replace",
              }
            end,
          },
        },
        opts = function(_, opts)
          opts.sources = opts.sources or {}
          opts.sources.default = vim.list_extend(opts.sources.default, {
            "avante_commands",
            "avante_mentions",
            "avante_files",
          })
          opts.sources.providers = vim.tbl_extend("force", opts.sources.providers, {
            avante_commands = {
              name = "avante_commands",
              module = "blink.compat.source",
              score_offset = 90, -- show at a higher priority than lsp
              opts = {},
            },
            avante_files = {
              name = "avante_files",
              module = "blink.compat.source",
              score_offset = 100, -- show at a higher priority than lsp
              opts = {},
            },
            avante_mentions = {
              name = "avante_mentions",
              module = "blink.compat.source",
              score_offset = 1000, -- show at a higher priority than lsp
              opts = {},
            },
          })
        end,
      },
    },
  },
  {
    "CopilotChat.nvim",
    branch = "main",
    version = false,
    optional = true,
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)
          local prefix = "<Leader>P"

          local function copilotChatClearDiagnostics()
            local ns = vim.api.nvim_create_namespace "copilot_review"
            vim.diagnostic.reset(ns)
          end

          vim.api.nvim_create_user_command("CopilotChatClearDiagnostics", copilotChatClearDiagnostics, {})

          local toggle_chat_mapping = { "<cmd>CopilotChatToggle<cr>", desc = "Toggle Chat" }
          maps.n[prefix .. "P"] = toggle_chat_mapping
          maps.v[prefix .. "P"] = { "<esc>" .. toggle_chat_mapping[1], desc = toggle_chat_mapping.desc }
          maps.n[prefix .. "C"] = { "<cmd>CopilotChatClearDiagnostics<cr>", desc = "Clear Chat Diagnostics" }
        end,
      },
    },
  },
  {
    "GeorgesAlkhouri/nvim-aider",
    cmd = { "Aider" },
    dependencies = {
      { "folke/snacks.nvim" },
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)
          local prefix = "<D-a>"
          for _, mode in ipairs { "n", "v", "s", "x", "o", "i", "t" } do
            maps[mode][prefix .. "s"] = { "<cmd>Aider send<cr>", desc = "Send to Aider" }
            maps[mode][normalize_keymap "<D-I>"] = { "<cmd>Aider toggle<cr>", desc = "Open Aider" }
            maps[mode][prefix .. prefix] = { "<cmd>Aider command<cr>", desc = "Send Command To Aider" }
            maps[mode][prefix .. "c"] = { "<cmd>Aider command<cr>", desc = "Send Command To Aider" }
            maps[mode][prefix .. "b"] = { "<cmd>Aider buffer<cr>", desc = "Send Buffer To Aider" }
            maps[mode][prefix .. "a"] = { "<cmd>Aider add<cr>", desc = "Add File to Aider" }
            maps[mode][prefix .. "d"] = { "<cmd>Aider drop<cr>", desc = "Drop File from Aider" }
            maps[mode][prefix .. "r"] = { "<cmd>Aider add readonly<cr>", desc = "Add File as Read-Only" }
            maps[mode][prefix .. "h"] = { "<cmd>Aider health<cr>", desc = "Aider Health" }
          end
        end,
      },
    },
    specs = {
      {
        "catppuccin",
        optional = true,
      },
      {
        "neo-tree.nvim",
        optional = true,
        opts = function(_, opts)
          -- Example mapping configuration (already set by default)
          -- opts.window = {
          --   mappings = {
          --     ["+"] = { "nvim_aider_add", desc = "add to aider" },
          --     ["-"] = { "nvim_aider_drop", desc = "drop from aider" }
          --   }
          -- }
          require("nvim_aider.neo_tree").setup(opts)
        end,
      },
    },
    opts = {
      win = {
        height = 0.6,
      },
    },
  },
}
