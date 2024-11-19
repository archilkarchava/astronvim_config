-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  {
    "neotest",
    optional = true,
    version = false,
    opts = {
      discovery = {
        enabled = true,
        filter_dir = function(name) return name ~= "node_modules" end,
      },
    },
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
          local maps = assert(opts.mappings)

          local prefix = "<Leader>T"

          maps.n[prefix .. "l"] = {
            function() require("neotest").run.run_last() end,
            desc = "Run last test",
          }
        end,
      },
    },
  },
  {
    "neotest",
    optional = true,
    dependencies = {
      {
        "neotest-jest",
        optional = true,
        opts = {
          cwd = function(file)
            local lib = require "neotest.lib"
            local root_path = lib.files.match_root_pattern "package.json"(file)
            return root_path or vim.fn.getcwd()
          end,
          jest_test_discovery = false,
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
