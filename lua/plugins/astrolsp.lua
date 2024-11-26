-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local function is_client(client_name)
  return function(client) return client.name == client_name end
end

local is_gopls_client = is_client "gopls"
local is_vtsls_client = is_client "vtsls"

---@param value boolean | nil
local function set_gofumpt(value)
  local cur_buf_clients = vim.lsp.get_clients { name = "gopls", bufnr = 0 }
  if not next(cur_buf_clients) then
    vim.notify("gopls client is not attached to the current buffer", vim.log.levels.WARN)
    return
  end
  --- @type boolean | nil
  local prev_value
  local new_value = value
  for _, client in ipairs(cur_buf_clients) do
    prev_value = client.config.settings.gopls.gofumpt
    if type(value) == "boolean" then
      new_value = value
    else
      new_value = not prev_value
    end
    client.config.settings.gopls.gofumpt = new_value
    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  end
  vim.notify(new_value and "Enabled gofumpt for the current client" or "Disabled gofumpt for the current client")
end

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      -- Configuration table of features provided by AstroLSP
      features = {
        autoformat = true, -- enable or disable auto formatting on start
        codelens = true, -- enable/disable codelens refresh on start
        inlay_hints = false, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
        signature_help = true, -- enable/disable signature help on start
      },
      -- customize lsp formatting options
      formatting = {
        -- control auto formatting on save
        format_on_save = {
          enabled = true, -- enable or disable format on save globally
          allow_filetypes = { -- enable format on save for specified filetypes only
            -- "go",
          },
          ignore_filetypes = { -- disable format on save for specified filetypes
            -- "python",
          },
        },
        disabled = { -- disable formatting capabilities for the listed language servers
          -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
          -- "lua_ls",
        },
        timeout_ms = 1000, -- default format timeout
        -- filter = function(client) -- fully override the default formatting function
        --   return true
        -- end
      },
      -- enable servers that you already have installed without mason
      servers = {
        -- "pyright"
      },
      -- customize language server configuration options passed to `lspconfig`
      ---@diagnostic disable: missing-fields
      config = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = false,
            },
          },
        },
        -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
        vtsls = {
          settings = {
            typescript = {
              format = {
                enable = false,
              },
              updateImportsOnFileMove = { enabled = "always" },
              tsserver = {
                useSeparateSyntaxServer = false,
                useSyntaxServer = "never",
                maxTsServerMemory = 8192,
              },
            },
            javascript = {
              format = {
                enable = false,
              },
              suggest = {
                names = false,
              },
            },
            vtsls = {
              autoUseWorkspaceTsdk = false,
              tsserver = {
                globalPlugins = {
                  {
                    -- pnpm -g install @styled/typescript-styled-plugin
                    name = "@styled/typescript-styled-plugin",
                    location = vim.fn.expand "$PNPM_HOME/global/5/node_modules",
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
          },
          root_dir = function(...)
            local util = require "lspconfig.util"
            return util.root_pattern("tsconfig.json", "jsconfig.json")(...)
              or util.root_pattern("package.json", ".git")(...)
          end,
        },
        graphql = {
          filetypes = { "graphql", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" },
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".graphqlrc*", ".graphql.config.*", "graphql.config.*")(...)
          end,
        },
        stylelint_lsp = {
          settings = {
            stylelintplus = {
              autoFixOnFormat = true,
              autoFixOnSave = true,
            },
          },
          on_attach = function(client) client.server_capabilities.codeActionProvider = false end,
          filetypes = {
            "css",
            "scss",
            "postcss",
            "less",
            "sass",
            "html",
            "svelte",
            "sugarss",
            "vue",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(
              "stylelint.config.js",
              ".stylelintrc.js",
              ".stylelintrc",
              "stylelint.config.mjs",
              ".stylelintrc.mjs",
              "stylelint.config.cjs",
              ".stylelintrc.cjs",
              ".stylelintrc.json",
              ".stylelintrc.yml",
              ".stylelintrc.yaml"
            )(...)
          end,
        },
      },
      -- customize how language servers are attached
      handlers = {
        -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
        -- function(server, opts) require("lspconfig")[server].setup(opts) end

        -- the key is the server that is being setup with `lspconfig`
        -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
        -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
      },
      -- Configure buffer local auto commands to add when attaching a language server
      autocmds = {
        -- first key is the `augroup` to add the auto commands to (:h augroup)
        lsp_codelens_refresh = {
          -- Optional condition to create/delete auto command group
          -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
          -- condition will be resolved for each client on each execution and if it ever fails for all clients,
          -- the auto commands will be deleted for that buffer
          cond = "textDocument/codeLens",
          -- cond = function(client, bufnr) return client.name == "lua_ls" end,
          -- list of auto commands to set
          {
            -- events to trigger
            event = { "InsertLeave", "BufEnter" },
            -- the rest of the autocmd options (:h nvim_create_autocmd)
            desc = "Refresh codelens (buffer)",
            callback = function(args)
              if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
            end,
          },
        },
      },
      -- mappings to be set up on attaching of a language server
      mappings = {
        n = {
          K = {
            ---@diagnostic disable-next-line: redundant-parameter
            function() vim.lsp.buf.hover { silent = true } end,
            desc = "LSP hover",
          },
          -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
          gD = {
            function() vim.lsp.buf.declaration() end,
            desc = "Declaration of current symbol",
            cond = "textDocument/declaration",
          },
          ["<Leader>uY"] = {
            function() require("astrolsp.toggles").buffer_semantic_tokens() end,
            desc = "Toggle LSP semantic highlight (buffer)",
            cond = function(client)
              return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens
            end,
          },
        },
        i = {
          ["<C-s>"] = {
            function() vim.lsp.buf.signature_help() end,
            desc = "Signature help",
            cond = "textDocument/signatureHelp",
          },
        },
      },
      commands = {
        GofumptEnable = {
          function() set_gofumpt(true) end,
          cond = is_gopls_client,
          desc = "Enable gofumpt",
        },
        GofumptDisable = {
          function() set_gofumpt(false) end,
          cond = is_gopls_client,
          desc = "Disable gofumpt",
        },
        GofumptToggle = {
          function() set_gofumpt() end,
          cond = is_gopls_client,
          desc = "Toggle gofumpt",
        },
        GofumptStatus = {
          function()
            local cur_buf_clients = vim.lsp.get_clients { name = "gopls", bufnr = 0 }
            if not next(cur_buf_clients) then
              vim.notify("gopls client is not attached to the current buffer", vim.log.levels.WARN)
              return
            end
            local is_gofumpt_enabled = cur_buf_clients[1].config.settings.gopls.gofumpt
            vim.notify(
              is_gofumpt_enabled and "gofumpt is enabled for the current client"
                or "gofumpt is disabled for the current client"
            )
          end,
          cond = is_gopls_client,
          desc = "Show gofumpt status",
        },
      },
      -- A custom `on_attach` function to be run after the default `on_attach` function
      -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
      on_attach = function(client, bufnr)
        -- this would disable semanticTokensProvider for all clients
        -- client.server_capabilities.semanticTokensProvider = nil
      end,
    },
  },
  {
    "yioneko/nvim-vtsls",
    optional = true,
    dependencies = {
      "AstroNvim/astrolsp",
      ---@type AstroLSPOpts
      opts = {
        commands = {
          RestartTypeScriptServer = {
            function() require("vtsls").commands.restart_tsserver() end,
            desc = "TypeScript: Restart TSServer",
            cond = is_vtsls_client,
          },
          SelectTypeScriptVersion = {
            function() require("vtsls").commands.select_ts_version() end,
            desc = "TypeScript: Select TypeScript version",
            cond = is_vtsls_client,
          },
        },
      },
    },
  },
  {
    "zeioth/garbage-day.nvim",
    optional = true,
    opts = {
      excluded_lsp_clients = {
        "null-ls",
        "jdtls",
        "marksman",
        "lua_ls",
        "copilot",
      },
    },
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = {
          mappings = {
            n = {
              ["<Leader>lc"] = {
                function()
                  require("garbage-day.utils").stop_lsp()
                  require("garbage-day.utils").start_lsp()
                end,
                desc = "Garbage collect LSP clients",
                remap = true,
              },
            },
          },
        },
      },
    },
  },
}
