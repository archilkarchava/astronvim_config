-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "nvim-dap",
  optional = true,
  dependencies = {
    {
      "overseer.nvim",
      optional = false,
      opts = {
        strategy = {
          "jobstart",
          use_terminal = true,
        },
        -- strategy = {
        --   "toggleterm",
        --   quit_on_exit = "success",
        --   open_on_start = false,
        -- },
      },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        local prefix = "<Leader>d"
        maps.n[prefix .. "l"] = { function() require("dap").run_last() end, desc = "Run the last debug session again" }
      end,
    },
  },
  opts = function()
    local dap = require "dap"
    local homebrew_prefix = os.getenv "HOMEBREW_PREFIX" or "/opt/homebrew"
    if not dap.adapters.lldb then
      dap.adapters.lldb = {
        type = "executable",
        command = homebrew_prefix .. "/opt/llvm/bin/lldb-dap",
        name = "lldb",
      }
    end
  end,
}
