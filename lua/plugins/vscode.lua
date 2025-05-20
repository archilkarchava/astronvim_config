if not vim.g.vscode then return {} end

return {
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      local platform = require "util.platform"
      local is_macos = platform.is_macos()
      local vsc = require "util.vsc"
      local maps = assert(opts.mappings)

      ---Used to generate OS-specific keymaps
      ---@param key_bind string
      ---@return string
      local function ctrl_cmd_lhs(key_bind)
        local default_primary_mod_key = is_macos and "D" or "C"
        return "<" .. default_primary_mod_key .. "-" .. key_bind .. ">"
      end

      maps.n["Q"] = "<nop>"

      ---@param direction "up" | "down"
      local function move_wrapped(direction)
        return vsc.call(
          "cursorMove",
          { args = { { to = direction, by = "wrappedLine", value = vim.v.count1 } }, count = 1 }
        )
      end
      maps.v["gk"] = function() move_wrapped "up" end
      maps.v["gj"] = function() move_wrapped "down" end

      maps.n["<leader>l"] = {
        function() vsc.action("codelens.showLensesInCurrentLine", { count = 1 }) end,
        desc = "Show CodeLens Commands For Current Line",
      }

      maps.n["gcc"] = "<Plug>VSCodeCommentaryLine"
      maps.n[ctrl_cmd_lhs "/"] = "<Plug>VSCodeCommentaryLine"
      for _, mode in ipairs { "x", "o" } do
        maps[mode][ctrl_cmd_lhs "/"] = "<Plug>VSCodeCommentary"
      end
      for _, mode in ipairs { "n", "x", "o" } do
        maps[mode]["gc"] = "<Plug>VSCodeCommentary"
      end
      if is_macos then
        maps.n["<C-/>"] = "<C-/>"
        maps.x["<C-/>"] = "<C-/>"
      end

      for _, mode in ipairs { "n", "x" } do
        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "c"] = function() vsc.action "editor.action.addCommentLine" end
        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "u"] = function() vsc.action "editor.action.removeCommentLine" end

        maps[mode]["<M-A>"] = function() vsc.action "editor.action.blockComment" end
      end

      for _, mode in ipairs { "n", "v" } do
        maps[mode]["<C-h>"] = function() vsc.action "workbench.action.navigateLeft" end
        maps[mode]["<C-k>"] = function() vsc.action "workbench.action.navigateUp" end
        maps[mode]["<C-l>"] = function() vsc.action "workbench.action.navigateRight" end
        maps[mode]["<C-j>"] = function() vsc.action "workbench.action.navigateDown" end
        maps[mode]["<C-w><C-k>"] = function() vsc.action "workbench.action.moveEditorToAboveGroup" end

        maps[mode]["<C-y>"] = function() vsc.action "germanScroll.arminUp" end
        maps[mode]["<C-e>"] = function() vsc.action "germanScroll.arminDown" end
        ---@param direction "up"|"down"
        local function scroll_half_page(direction)
          local vscode_command = direction == "up" and "germanScroll.bertholdUp" or "germanScroll.bertholdDown"
          vsc.action(vscode_command, {
            callback = function() vim.cmd "normal zz" end,
          })
        end
        maps[mode]["<C-u>"] = function() scroll_half_page "up" end
        maps[mode]["<C-d>"] = function() scroll_half_page "down" end
        maps[mode]["<C-b>"] = function() vsc.action "germanScroll.christaUp" end
        maps[mode]["<C-f>"] = function() vsc.action "germanScroll.christaDown" end
      end

      maps.n["zh"] = function() vsc.action "scrollLeft" end
      maps.n["z<Left>"] = function() vsc.action "scrollLeft" end
      maps.n["zl"] = function() vsc.action "scrollRight" end
      maps.n["z<Right>"] = function() vsc.action "scrollRight" end
      maps.n["zH"] = function() vsc.action("scrollLeft", { count = 10000 }) end
      maps.n["zL"] = function() vsc.action("scrollRight", { count = 10000 }) end

      maps.n[ctrl_cmd_lhs "Enter"] = "o<Esc>"
      maps.n[ctrl_cmd_lhs "S-Enter"] = "O<Esc>"

      maps.n[ctrl_cmd_lhs "l"] = "0vj"
      maps.x[ctrl_cmd_lhs "l"] = function() vsc.action "expandLineSelection" end
      maps.n[ctrl_cmd_lhs "t"] = function() vsc.action("workbench.action.showAllSymbols", { count = 1 }) end
      maps.x[ctrl_cmd_lhs "t"] = {
        function()
          vsc.action("workbench.action.showAllSymbols", {
            callback = function()
              local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
              vim.api.nvim_feedkeys(esc, "m", false)
            end,
            count = 1,
          })
        end,
        expr = true,
      }
      -- maps.n[ctrl_cmd_lhs "L"] = {
      --   function()
      --     vim.api.nvim_feedkeys("i", "m", false)
      --     vsc.action("editor.action.selectHighlights", { count = 1 })
      --   end,
      --   expr = true,
      -- }
      -- maps.x[ctrl_cmd_lhs "L"] =
      --   { function() vsc.action_insert_selection("editor.action.selectHighlights", { count = 1 }) end, expr = true }

      for _, mode in ipairs { "n", "x" } do
        maps[mode]["<Leader>ae"] = function() vsc.action("inlineChat.start", { count = 1 }) end
      end

      for _, mode in ipairs { "n", "x" } do
        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "r"] = function()
          vsc.action("git.revertSelectedRanges", { count = 1 })
        end
        maps[mode]["<Leader>gr"] = function() vsc.action("git.revertSelectedRanges", { count = 1 }) end
        maps[mode]["<Leader>gs"] = function() vsc.action("git.stageSelectedRanges", { count = 1 }) end
        maps[mode]["<Leader>gu"] = function() vsc.action("git.unstageSelectedRanges", { count = 1 }) end

        maps[mode]["]g"] = function()
          vsc.action "workbench.action.editor.nextChange"
          vsc.action "workbench.action.compareEditor.nextChange"
        end
        maps[mode]["[g"] = function()
          vsc.action "workbench.action.editor.previousChange"
          vsc.action "workbench.action.compareEditor.previousChange"
        end
      end
      maps.n["<Leader>gR"] = function() vsc.action("git.clean", { count = 1 }) end
      maps.n["<Leader>gS"] = function()
        vsc.action("git.stageFile", { count = 1 })
        vsc.action("git.stage", { count = 1 })
      end
      maps.n["<Leader>gU"] = function()
        vsc.action("git.unstage", { count = 1 })
        vsc.action("git.unstageFile", { count = 1 })
      end

      for _, mode in ipairs { "n", "v" } do
        maps[mode]["<Leader>gp"] = function() vsc.action "editor.action.dirtydiff.next" end
        maps[mode]["<Leader>]g"] = function() vsc.action "editor.action.dirtydiff.next" end
        maps[mode]["<Leader>[g"] = function() vsc.action "editor.action.dirtydiff.previous" end
      end

      maps.n["<Leader>gC"] = function() vsc.action "merge-conflict.accept.all-current" end
      maps.n["<Leader>gI"] = function() vsc.action "merge-conflict.accept.all-incoming" end
      maps.n["<Leader>gB"] = function() vsc.action "merge-conflict.accept.all-both" end
      maps.n["<Leader>gc"] = function() vsc.action "merge-conflict.accept.current" end
      maps.n["<Leader>gi"] = function() vsc.action "merge-conflict.accept.incoming" end
      maps.n["<Leader>gb"] = function() vsc.action "merge-conflict.accept.both" end
      maps.v["<Leader>ga"] = function() vsc.action "merge-conflict.accept.selection" end
      for _, mode in ipairs { "n", "v" } do
        maps[mode]["]x"] = function() vsc.action "merge-conflict.next" end
        maps[mode]["[x"] = function() vsc.action "merge-conflict.previous" end
        maps[mode]["<Leader>]x"] = function() vsc.action "merge.goToNextUnhandledConflict" end
        maps[mode]["<Leader>[x"] = function() vsc.action "merge.goToPreviousUnhandledConflict" end
        maps[mode]["]d"] = function() vsc.action "editor.action.marker.next" end
        maps[mode]["[d"] = function() vsc.action "editor.action.marker.prev" end
      end
      maps.n["<Leader>]d"] = function() vsc.action "editor.action.marker.nextInFiles" end
      maps.n["<Leader>[d"] = function() vsc.action "editor.action.marker.prevInFiles" end

      ---@param direction "next"|"previous"
      local function go_to_breakpoint(direction)
        local vscode_command = direction == "next" and "editor.debug.action.goToNextBreakpoint"
          or "editor.debug.action.goToPreviousBreakpoint"
        vsc.action(vscode_command, {
          callback = function()
            vsc.action("workbench.action.focusActiveEditorGroup", {
              callback = function()
                local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
                vim.api.nvim_feedkeys(esc .. "^", "m", false)
              end,
              count = 1,
            })
          end,
          count = 1,
        })
      end

      maps.n["]b"] = function() go_to_breakpoint "next" end
      maps.v["]b"] = function() go_to_breakpoint "next" end
      maps.n["[b"] = function() go_to_breakpoint "previous" end
      maps.v["[b"] = function() go_to_breakpoint "previous" end

      maps.n["<Leader>m"] = function() vsc.action "bookmarks.toggle" end
      maps.n["<Leader>M"] = function() vsc.action "bookmarks.listFromAllFiles" end
      maps.n["<Leader>B"] = function() vsc.action "editor.debug.action.toggleBreakpoint" end
      maps.n[ctrl_cmd_lhs "]"] = function() vsc.action "editor.action.indentLines" end
      maps.x[ctrl_cmd_lhs "]"] = function() vsc.action "editor.action.indentLines" end
      maps.n[ctrl_cmd_lhs "["] = function() vsc.action "editor.action.outdentLines" end
      maps.x[ctrl_cmd_lhs "["] = function() vsc.action "editor.action.outdentLines" end
      maps.n["<Leader>un"] = function() vsc.action "notifications.hideToasts" end
      maps.x["<Leader>un"] = function() vsc.action "notifications.hideToasts" end
      maps.n["<Leader>*"] = function()
        vsc.action("workbench.action.findInFiles", {
          args = { { query = vim.fn.expand "<cword>" } },
          count = 1,
        })
      end
      maps.x["<Leader>*"] = function()
        vsc.action("workbench.action.findInFiles", {
          args = { { query = vsc.get_visual_selection() } },
          count = 1,
        })
      end
      maps.n["<leader>/"] = function() vsc.action("workbench.action.findInFiles", { count = 1 }) end

      -- Folding
      for _, mode in ipairs { "n", "x" } do
        maps[mode]["za"] = function() vsc.action "editor.toggleFold" end
        maps[mode]["zR"] = function() vsc.action "editor.unfoldAll" end
        maps[mode]["zM"] = function() vsc.action "editor.foldAll" end
        maps[mode]["zo"] = function() vsc.action "editor.unfold" end
        maps[mode]["zO"] = function() vsc.action "editor.unfoldRecursively" end
        maps[mode]["zc"] = function() vsc.action "editor.fold" end
        maps[mode]["zC"] = function() vsc.action "editor.foldRecursively" end

        maps[mode]["z1"] = function() vsc.action "editor.foldLevel1" end
        maps[mode]["z2"] = function() vsc.action "editor.foldLevel2" end
        maps[mode]["z3"] = function() vsc.action "editor.foldLevel3" end
        maps[mode]["z4"] = function() vsc.action "editor.foldLevel4" end
        maps[mode]["z5"] = function() vsc.action "editor.foldLevel5" end
        maps[mode]["z6"] = function() vsc.action "editor.foldLevel6" end
        maps[mode]["z7"] = function() vsc.action "editor.foldLevel7" end

        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "1"] = function() vsc.action "editor.foldLevel1" end
        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "2"] = function() vsc.action "editor.foldLevel2" end
        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "3"] = function() vsc.action "editor.foldLevel3" end
        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "4"] = function() vsc.action "editor.foldLevel4" end
        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "5"] = function() vsc.action "editor.foldLevel5" end
        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "6"] = function() vsc.action "editor.foldLevel6" end
        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "7"] = function() vsc.action "editor.foldLevel7" end

        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs ","] = function()
          vsc.action("editor.createFoldingRangeFromSelection", {
            callback = function()
              local sel_start = vim.fn.getpos "v"
              local sel_end = vim.fn.getpos "."
              if sel_end[2] > sel_start[2] then vim.api.nvim_feedkeys("o", "m", false) end
              local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
              vim.api.nvim_feedkeys(esc, "m", false)
            end,
            count = 1,
          })
        end

        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "."] = {
          function()
            vsc.call "editor.removeManualFoldingRanges"
            return "<esc>"
          end,
          expr = true,
        }

        maps[mode]["zV"] = function() vsc.action "editor.foldAllExcept" end
        maps[mode]["zX"] = function() vsc.action "editor.removeManualFoldingRanges" end

        maps[mode]["]z"] = function() vsc.action "editor.gotoNextFold" end
        maps[mode]["[z"] = function() vsc.action "editor.gotoPreviousFold" end
      end

      maps.x[ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "["] = function() vsc.action "editor.foldRecursively" end
      maps.x[ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "]"] = function() vsc.action "editor.unfoldRecursively" end

      maps.x[ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "-"] = function() vsc.action "editor.foldAllExcept" end
      maps.x[ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "="] = function() vsc.action "editor.unfoldAllExcept" end

      maps.x["zx"] = {
        function()
          vsc.call "editor.createFoldingRangeFromSelection"
          return "<esc>"
        end,
        expr = true,
      }

      -- Jumplist
      -- maps.n["<M-O>"] = "<C-o>"
      -- maps.n["<M-I>"] = "<C-i>"

      -- The <M-O> and <M-I> will be set by the mini.bracketed plugin
      -- maps.n["<M-O>"] = "<Cmd>call VSCodeNotify('workbench.action.openPreviousRecentlyUsedEditor')<CR>"
      -- maps.n["<M-I>"] = "<Cmd>call VSCodeNotify('workbench.action.openNextRecentlyUsedEditor')<CR>"

      maps.v["<C-o>"] = "<Cmd>call VSCodeNotify('workbench.action.navigateBack')<CR>"
      maps.v["<C-i>"] = "<Cmd>call VSCodeNotify('workbench.action.navigateForward')<CR>"

      maps.n["<Leader>`."] = "`."
      maps.n["`."] = "<Cmd>call VSCodeNotify('workbench.action.navigateToLastEditLocation')<CR>"
      maps.n["<Leader>g;"] = "g;"
      maps.n["<Leader>g,"] = "g,"
      maps.n["g;"] = "<Cmd>call VSCodeNotify('workbench.action.navigateBackInEditLocations')<CR>"
      maps.n["g,"] = "<Cmd>call VSCodeNotify('workbench.action.navigateForwardInEditLocations')<CR>"

      maps.n["gd"] = function() vsc.go_to_definition_marked "revealDefinition" end
      maps.n["<Leader>gd"] = function() vsc.go_to_definition_marked "goToTypeDefinition" end
      maps.n["<F12>"] = function() vsc.go_to_definition_marked "revealDefinition" end
      maps.n["gf"] = function() vsc.go_to_definition_marked "revealDeclaration" end
      maps.n["<C-]>"] = function() vsc.go_to_definition_marked "revealDefinition" end
      maps.n["gO"] = function() vsc.action_marked("workbench.action.gotoSymbol", { count = 1 }) end
      maps.n[ctrl_cmd_lhs "O"] = function() vsc.action_marked("workbench.action.gotoSymbol", { count = 1 }) end
      maps.n["gF"] = function() vsc.action_marked("editor.action.peekDeclaration", { count = 1 }) end
      maps.n["<S-F12>"] = function() vsc.action_marked("editor.action.goToReferences", { count = 1 }) end
      maps.n["gH"] = function() vsc.action_marked("editor.action.referenceSearch.trigger", { count = 1 }) end
      maps.n[ctrl_cmd_lhs "S-F12"] = function() vsc.action_marked("editor.action.peekImplementation", { count = 1 }) end
      maps.n["<M-S-F12>"] = function() vsc.action_marked("references-view.findReferences", { count = 1 }) end
      maps.n["gD"] = function() vsc.action_marked("editor.action.peekDefinition", { count = 1 }) end
      maps.n["<M-F12>"] = function() vsc.action_marked("editor.action.peekDefinition", { count = 1 }) end
      maps.n[ctrl_cmd_lhs "F12"] = function() vsc.action_marked("editor.action.goToImplementation", { count = 1 }) end

      maps.n[ctrl_cmd_lhs "."] = "<Cmd>call VSCodeNotify('editor.action.quickFix')<CR>"

      -- VSCode gx
      maps.n["gx"] = function() vsc.action("editor.action.openLink", { count = 1 }) end

      maps.n["<Leader>o"] = function() vsc.action("workbench.action.showOutputChannels", { count = 1 }) end
      maps.n["<Leader>li"] = function() vsc.action("workbench.action.showOutputChannels", { count = 1 }) end
      maps.n["<Leader>Ma"] = "<Cmd>call VSCodeNotify('workbench.action.tasks.runTask')<CR>"
      maps.n["<Leader>Mr"] = "<Cmd>call VSCodeNotify('workbench.action.tasks.runTask')<CR>"
      maps.n["<Leader>uc"] = "<Cmd>call VSCodeNotify('workbench.action.toggleCenteredLayout')<CR>"
      maps.n["<Leader>uT"] = function()
        vsc.action("runCommands", {
          args = {
            commands = {
              "editor.action.toggleStickyScroll",
              "workbench.action.terminal.toggleStickyScroll",
              "notebook.action.toggleNotebookStickyScroll",
              "tree.toggleStickyScroll",
            },
          },
        })
      end
      for _, mode in ipairs { "n", "x", "o" } do
        maps[mode]["[;"] = function()
          vsc.action("editor.action.focusStickyScroll", {
            callback = function(err)
              if not err then vsc.action "editor.action.goToFocusedStickyScrollLine" end
            end,
          })
        end
      end
      -- maps.n["<Leader>cc"] = function()
      --   vsc.action("codeium.toggleEnable", {
      --     callback = function(err)
      --       if not err then vsc.action "notifications.toggleList" end
      --     end,
      --   })
      -- end

      -- Undo/Redo
      for _, mode in ipairs { "n", "x" } do
        maps[mode][ctrl_cmd_lhs "z"] = "<Cmd>call VSCodeNotify('undo')<CR>"
        maps[mode][ctrl_cmd_lhs "Z"] = "<Cmd>call VSCodeNotify('redo')<CR>"
      end

      -- map("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>", opts)
      -- map("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>", opts)

      -- Insert snippets
      maps.n[ctrl_cmd_lhs "R"] = function()
        vim.api.nvim_feedkeys("i", "m", false)
        vsc.action("editor.action.showSnippets", { count = 1 })
      end

      maps.x[ctrl_cmd_lhs "R"] = function() vsc.action_insert_selection("editor.action.showSnippets", { count = 1 }) end

      -- Quick fixes and refactorings
      maps.n[ctrl_cmd_lhs "."] = "<Cmd>call VSCodeCall('editor.action.quickFix')<CR>"
      maps.x[ctrl_cmd_lhs "."] = function() vsc.action_insert_selection("editor.action.quickFix", { count = 1 }) end
      maps.n["<C-S-R>"] = function() vsc.action("editor.action.refactor", { count = 1 }) end
      maps.x["<C-S-R>"] = function() vsc.action_insert_selection("editor.action.refactor", { count = 1 }) end
      maps.x["<M-S-s>"] = function() vsc.action_insert_selection("editor.action.surroundWithSnippet", { count = 1 }) end
      maps.x["<M-T>"] = function() vsc.action_insert_selection("surround.with", { count = 1 }) end

      -- Formatting
      for _, mode in ipairs { "n", "x" } do
        maps[mode]["<M-F>"] = "<Cmd>call VSCodeCall('editor.action.formatDocument')<CR>"
        maps[mode][ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "f"] =
          "<Cmd>call VSCodeCall('editor.action.formatSelection', 1)<CR>"

        maps[mode]["<M-l>"] = function() vsc.action "editor.action.indentLines" end
        maps[mode]["<M-h>"] = function() vsc.action "editor.action.outdentLines" end
        maps[mode]["<M-D>"] = function() vsc.action "abracadabra.moveStatementDown" end
        maps[mode]["<M-U>"] = function() vsc.action "abracadabra.moveStatementUp" end
      end

      -- Harpoon
      local harpoon_prefix = "<Leader><Leader>"
      maps.n[harpoon_prefix .. "a"] = function() vsc.action("vscode-harpoon.addEditor", { count = 1 }) end
      maps.n[harpoon_prefix .. "d"] = function() vsc.action("vscode-harpoon.editorQuickPick", { count = 1 }) end
      maps.n[harpoon_prefix .. "s"] = function() vsc.action("vscode-harpoon.editEditors", { count = 1 }) end
      maps.n["<M-0>"] = function() vsc.action("vscode-harpoon.editEditors", { count = 1 }) end
      maps.n["<M-1>"] = function() vsc.action("vscode-harpoon.gotoEditor1", { count = 1 }) end
      maps.n["<M-2>"] = function() vsc.action("vscode-harpoon.gotoEditor2", { count = 1 }) end
      maps.n["<M-3>"] = function() vsc.action("vscode-harpoon.gotoEditor3", { count = 1 }) end
      maps.n["<M-4>"] = function() vsc.action("vscode-harpoon.gotoEditor4", { count = 1 }) end
      maps.n["<M-5>"] = function() vsc.action("vscode-harpoon.gotoEditor5", { count = 1 }) end
      maps.n["<M-6>"] = function() vsc.action("vscode-harpoon.gotoEditor6", { count = 1 }) end
      maps.n["<M-7>"] = function() vsc.action("vscode-harpoon.gotoEditor7", { count = 1 }) end
      maps.n["<M-8>"] = function() vsc.action("vscode-harpoon.gotoEditor8", { count = 1 }) end
      maps.n["<M-9>"] = function() vsc.action("vscode-harpoon.gotoEditor9", { count = 1 }) end

      maps.n["<Leader>W"] = function() vsc.action "workbench.action.files.saveWithoutFormatting" end

      -- Map <Esc> to jk to use with cmdline `norm` commands in VS Code
      maps.i["jk"] = "<Esc>"
      maps.i["ол"] = "<Esc>"
      maps.i["<C-g>"] = "<Esc>"
    end,
  },
  {
    "mini.splitjoin",
    optional = true,
    cond = true,
  },
  {
    "echasnovski/mini.bracketed",
    cond = true,
    optional = true,
    opts = {
      buffer = { suffix = "" },
      conflict = { suffix = "" },
      diagnostic = { suffix = "" },
      file = { suffix = "" },
      oldfile = { suffix = "" },
      quickfix = { suffix = "" },
      undo = { suffix = "" },
      window = { suffix = "" },
    },
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = assert(opts.mappings)
          maps.n["<M-O>"] = function() pcall(require("mini.bracketed").jump, "backward", { wrap = false }) end
          maps.n["<M-I>"] = function() pcall(require("mini.bracketed").jump, "forward", { wrap = false }) end
        end,
      },
    },
  },
  {
    "nvim-surround",
    optional = true,
    specs = {
      {
        "AstroNvim/astroui",
        ---@type AstroUIOpts
        opts = {
          highlights = {
            init = {
              NvimSurroundHighlight = { link = "IncSearch" },
              FakeVisual = { bg = "#45475b" },
            },
          },
        },
      },
    },
  },
  { "nvim-treesitter/nvim-treesitter", opts = { highlight = { enable = true } } },
}
