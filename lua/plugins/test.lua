-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  {
    "archilkarchava/neotest",
    optional = true,
    version = false,
    opts = {
      discovery = {
        enabled = true,
        filter_dir = function(name) return name ~= "node_modules" end,
      },
    },
  },
  {
    "neotest",
    optional = true,
    dependencies = {
      {
        "nvim-neotest/neotest-jest",
        optional = true,
        opts = {
          cwd = function(file)
            local lib = require "neotest.lib"
            local root_path = lib.files.match_root_pattern "package.json"(file)
            return root_path or vim.fn.getcwd()
          end,
          jest_test_discovery = true,
        },
      },
    },
  },
  {
    "neotest",
    optional = true,
    dependencies = {
      { "marilari88/neotest-vitest" },
    },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(
        opts.adapters,
        require "neotest-vitest" {
          vitestCommand = "bunx vitest",
          filter_dir = function(name) return name ~= "node_modules" end,
        }
      )
    end,
  },
}
