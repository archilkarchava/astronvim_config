-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@alias SuggestionsProvider "supermaven" | "copilot" | "none"

local suggestion_providers = {
  copilot = "copilot",
  supermaven = "supermaven",
  none = "none",
}

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
  accept_suggestion = { "<C-x>", accept_suggestion, desc = "Accept suggestion", noremap = true, silent = true },
  accept_word = { "<C-z>", accept_word, desc = "Accept word", noremap = true, silent = true },
  clear_suggestion = { "<C-]>", clear_suggestion, desc = "Clear suggestion", noremap = true, silent = true },
}

---@type LazySpec
return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
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
      require("copilot").setup(opts)
      if default_suggestions_provider ~= suggestion_providers.copilot then copilot_helpers.disable() end
    end,
  },
  {
    "archilkarchava/supermaven-nvim",
    -- event = "User AstroFile",
    event = "VeryLazy",
    opts = function(_, opts)
      return {
        keymaps = {
          accept_suggestion = keymaps.accept_suggestion[1],
          accept_word = keymaps.accept_word[1],
          clear_suggestion = keymaps.clear_suggestion[1],
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
          maps.i[keymaps.accept_suggestion[1]] = {
            keymaps.accept_suggestion[2],
            desc = keymaps.accept_suggestion.desc,
            noremap = keymaps.accept_suggestion.noremap,
            silent = keymaps.accept_suggestion.silent,
          }
          maps.i[keymaps.accept_word[1]] = {
            keymaps.accept_word[2],
            desc = keymaps.accept_word.desc,
            noremap = keymaps.accept_word.noremap,
            silent = keymaps.accept_word.silent,
          }
          maps.i[keymaps.clear_suggestion[1]] = {
            keymaps.clear_suggestion[2],
            desc = keymaps.clear_suggestion.desc,
            noremap = keymaps.clear_suggestion.noremap,
            silent = keymaps.clear_suggestion.silent,
          }

          local utils = require "astrocore"
          local prefix = "<Leader>i"

          maps.n[prefix] =
            { desc = require("astroui").get_icon("Suggestions", 1, true) .. "Inline suggestions provider" }
          maps.n[prefix .. "s"] = {
            function()
              copilot_helpers.disable()
              supermaven_helpers.enable()
              vim.g.current_suggestions_provider = suggestion_providers.supermaven
            end,
            desc = require("astroui").get_icon("Supermaven", 1, true) .. "Supermaven",
          }
          if utils.is_available "copilot.lua" then
            maps.n[prefix .. "c"] = {
              function()
                supermaven_helpers.disable()
                copilot_helpers.enable()
                vim.g.current_suggestions_provider = suggestion_providers.copilot
              end,
              desc = require("astroui").get_icon("Copilot", 1, true) .. "Copilot",
            }
          end
          maps.n[prefix .. "d"] = {
            function()
              supermaven_helpers.disable()
              copilot_helpers.disable()
              vim.g.current_suggestions_provider = suggestion_providers.none
            end,
            desc = "Disable all",
          }
          opts.autocmds.stop_supermaven = {
            {
              event = "LspAttach",
              desc = "Stop Supermaven when Copilot is attached",
              callback = supermaven_cond_toggle,
            },
          }
          opts.autocmds.start_supermaven = {
            {
              event = "LspDetach",
              desc = "Start Supermaven when Copilot is detached",
              callback = supermaven_cond_toggle,
            },
          }
        end,
      },
    },
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = ":AvanteBuild",
    opts = {
      ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
      provider = "copilot", -- Recommend using Claude
      auto_suggestions_provider = "copilot",
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
    },
    dependencies = {
      {
        "AstroNvim/astroui",
        opts = { icons = { Avante = "" } },
      },
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          local prefix = "<Leader>a"

          if maps.n[prefix] == nil then
            maps.n[prefix] = { desc = require("astroui").get_icon("Avante", 1, true) .. "Avante" }
          end
        end,
      },
      --- The below dependencies are optional,
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
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
    },
    specs = {
      { -- if copilot.lua is available, default to copilot provider
        "zbirenbaum/copilot.lua",
        optional = true,
        specs = {
          {
            "yetone/avante.nvim",
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
          if not opts.file_types then opts.filetypes = { "markdown" } end
          opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "Avante" })
        end,
      },
      {
        -- make sure `Avante` is added as a filetype
        "OXY2DEV/markview.nvim",
        optional = true,
        opts = function(_, opts)
          if not opts.filetypes then opts.filetypes = { "markdown", "quarto", "rmd" } end
          opts.filetypes = require("astrocore").list_insert_unique(opts.filetypes, { "Avante" })
        end,
      },
    },
  },
}
