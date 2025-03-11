-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

local tmp_dir = vim.env.TMPDIR or "/tmp"
local root_coverage_dir = vim.fs.joinpath(tmp_dir, "nvim-coverage")

local coverage_paths = {
  go = vim.fs.joinpath(root_coverage_dir, "go", "coverage.out"),
  javascript = vim.fs.joinpath(root_coverage_dir, "javascript", "lcov.info"),
}

---@type LazySpec
return {
  {
    "neotest",
    optional = true,
    version = false,
    opts = {
      discovery = {
        enabled = false,
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
    "overseer.nvim",
    optional = true,
    specs = {
      {
        "neotest",
        optional = true,
        opts = function(_, opts)
          local astrocore = require "astrocore"
          return astrocore.extend_tbl(opts, {
            consumers = {
              overseer = require "neotest.consumers.overseer",
            },
            overseer = {
              enabled = true,
              -- When this is true (the default), it will replace all neotest.run.* commands
              force_default = false,
            },
          })
        end,
      },
    },
  },
  {
    "neotest",
    optional = true,
    dependencies = {
      { "archilkarchava/neotest-jest" },
    },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(
        opts.adapters,
        require "neotest-jest" {
          cwd = function(file)
            local lib = require "neotest.lib"
            local root_path = lib.files.match_root_pattern "package.json"(file)
            return root_path or vim.fn.getcwd()
          end,
          jestCommand = "npm exec jest --",
          jest_test_discovery = false,
        }
      )
    end,
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
          vitestCommand = "npm exec vitest --",
          filter_dir = function(name) return name ~= "node_modules" end,
        }
      )
    end,
  },
  {
    "nvim-coverage",
    optional = true,
    opts = {
      auto_reload = true,
      lang = {
        go = {
          coverage_file = coverage_paths.go,
        },
        javascript = {
          coverage_file = coverage_paths.javascript,
        },
      },
    },
    init = function()
      for _, path in pairs(coverage_paths) do
        local coverage_dir = vim.fn.fnamemodify(path, ":h")
        vim.fn.mkdir(coverage_dir, "p")
      end
    end,
    dependencies = {
      {
        "neotest",
        optional = true,
        dependencies = {
          {
            "AstroNvim/astrocore",
            opts = function(_, opts)
              local maps = opts.mappings

              local get_file_path = function() return vim.fn.expand "%" end
              local get_project_path = function() return vim.fn.getcwd() end

              local tests_prefix = "<Leader>T"
              local coverage_prefix = tests_prefix .. "C"

              ---@param bool boolean
              local function bool2str(bool) return bool and "on" or "off" end

              ---@param enabled boolean
              local function notify_coverage_collection_state(enabled)
                return require("astrocore").notify(("coverage collection %s"):format(bool2str(enabled)))
              end

              local coverage_collection_enabled = false
              local coverage = require "coverage"
              local coverage_report = require "coverage.report"

              local function load_or_show_cached_coverage()
                if vim.bo.filetype == coverage_report.language() and coverage_report.is_cached() then
                  coverage.show()
                else
                  coverage.load(true)
                end
              end

              maps.n[coverage_prefix .. "T"] = {
                function()
                  coverage_collection_enabled = not coverage_collection_enabled
                  if coverage_collection_enabled then
                    load_or_show_cached_coverage()
                  else
                    coverage.hide()
                  end
                  notify_coverage_collection_state(coverage_collection_enabled)
                end,
                desc = "Toggle coverage collection",
              }

              ---@class NeotestRunArgs : neotest.run.RunArgs
              ---@field run_last boolean Run last test

              ---@param args string|NeotestRunArgs? Position ID to run or args.
              local function neotest_run(args)
                local neotest = require "neotest"
                args = args or {}
                args = type(args) == "string" and { args } or args
                if coverage_collection_enabled then
                  local filetype = vim.bo.filetype
                  if
                    filetype == "javascript"
                    or filetype == "javascriptreact"
                    or filetype == "typescript"
                    or filetype == "typescriptreact"
                  then
                    args.extra_args =
                      { "--coverage", "--coverageDirectory=" .. vim.fn.fnamemodify(coverage_paths.javascript, ":h") }
                  elseif filetype == "go" then
                    args.extra_args = { "-coverprofile=" .. coverage_paths.go }
                  end
                end
                local run_method = args.run_last and "run_last" or "run"
                neotest.run[run_method](args)
              end

              maps.n[tests_prefix .. "t"] = {
                function() neotest_run() end,
                desc = "Run test",
              }
              maps.n[tests_prefix .. "f"] = {
                function() neotest_run(get_file_path()) end,
                desc = "Run all tests in file",
              }
              maps.n[tests_prefix .. "p"] = {
                function() neotest_run(get_project_path()) end,
                desc = "Run all tests in project",
              }
              maps.n[tests_prefix .. "l"] = {
                function() neotest_run { run_last = true } end,
                desc = "Run last test",
              }
            end,
          },
        },
      },
    },
  },
}
