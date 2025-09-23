if not vim.g.vscode then return {} end

local platform = require "util.platform"
local is_macos = platform.is_macos()
local vsc = require "util.vsc"

---@param key_bind string
---@return string
local function ctrl_cmd_lhs(key_bind)
  local default_primary_mod_key = is_macos and "D" or "C"
  return "<" .. default_primary_mod_key .. "-" .. key_bind .. ">"
end

---@param direction "up" | "down"
local function move_wrapped(direction)
  return vsc.call("cursorMove", { args = { { to = direction, by = "wrappedLine", value = vim.v.count1 } }, count = 1 })
end

---@param direction "next" | "previous"
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

---@param direction "up" | "down"
local function scroll_half_page(direction)
  local vscode_command = direction == "up" and "germanScroll.bertholdUp" or "germanScroll.bertholdDown"
  vsc.action(vscode_command, {
    callback = function() vim.cmd "normal zz" end,
  })
end

local harpoon_prefix = "<Leader><Leader>"

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("v", "gk", function() move_wrapped "up" end)
vim.keymap.set("v", "gj", function() move_wrapped "down" end)
vim.keymap.set(
  "n",
  "<leader>l",
  function() vsc.action("codelens.showLensesInCurrentLine", { count = 1 }) end,
  { desc = "Show CodeLens Commands For Current Line" }
)
vim.keymap.set("n", "gcc", "<Plug>VSCodeCommentaryLine")
vim.keymap.set("n", ctrl_cmd_lhs "/", "<Plug>VSCodeCommentaryLine")
vim.keymap.set({ "x", "o" }, ctrl_cmd_lhs "/", "<Plug>VSCodeCommentary")
vim.keymap.set({ "n", "x", "o" }, "gc", "<Plug>VSCodeCommentary")
if is_macos then vim.keymap.set({ "n", "x" }, "<C-/>", "<C-/>") end
vim.keymap.set(
  { "n", "x" },
  ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "c",
  function() vsc.action "editor.action.addCommentLine" end
)
vim.keymap.set(
  { "n", "x" },
  ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "u",
  function() vsc.action "editor.action.removeCommentLine" end
)
vim.keymap.set({ "n", "x" }, "<M-A>", function() vsc.action "editor.action.blockComment" end)
vim.keymap.set({ "n", "v" }, "<C-h>", function() vsc.action "workbench.action.navigateLeft" end)
vim.keymap.set({ "n", "v" }, "<C-k>", function() vsc.action "workbench.action.navigateUp" end)
vim.keymap.set({ "n", "v" }, "<C-l>", function() vsc.action "workbench.action.navigateRight" end)
vim.keymap.set({ "n", "v" }, "<C-j>", function() vsc.action "workbench.action.navigateDown" end)
vim.keymap.set({ "n", "v" }, "<C-w><C-k>", function() vsc.action "workbench.action.moveEditorToAboveGroup" end)
vim.keymap.set({ "n", "v" }, "<C-y>", function() vsc.action "germanScroll.arminUp" end)
vim.keymap.set({ "n", "v" }, "<C-e>", function() vsc.action "germanScroll.arminDown" end)
vim.keymap.set({ "n", "v" }, "<C-u>", function() scroll_half_page "up" end)
vim.keymap.set({ "n", "v" }, "<C-d>", function() scroll_half_page "down" end)
vim.keymap.set({ "n", "v" }, "<C-b>", function() vsc.action "germanScroll.christaUp" end)
vim.keymap.set({ "n", "v" }, "<C-f>", function() vsc.action "germanScroll.christaDown" end)
vim.keymap.set("n", "zh", function() vsc.action "scrollLeft" end)
vim.keymap.set("n", "z<Left>", function() vsc.action "scrollLeft" end)
vim.keymap.set("n", "zl", function() vsc.action "scrollRight" end)
vim.keymap.set("n", "z<Right>", function() vsc.action "scrollRight" end)
vim.keymap.set("n", "zH", function() vsc.action("scrollLeft", { count = 10000 }) end)
vim.keymap.set("n", "zL", function() vsc.action("scrollRight", { count = 10000 }) end)
vim.keymap.set("n", ctrl_cmd_lhs "Enter", "o<Esc>")
vim.keymap.set("n", ctrl_cmd_lhs "S-Enter", "O<Esc>")
vim.keymap.set("n", ctrl_cmd_lhs "l", "0vj")
vim.keymap.set("x", ctrl_cmd_lhs "l", function() vsc.action "expandLineSelection" end)
vim.keymap.set("n", ctrl_cmd_lhs "t", function() vsc.action("workbench.action.showAllSymbols", { count = 1 }) end)
vim.keymap.set("x", ctrl_cmd_lhs "t", function()
  vsc.action("workbench.action.showAllSymbols", {
    callback = function()
      local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
      vim.api.nvim_feedkeys(esc, "m", false)
    end,
    count = 1,
  })
end, { expr = true })
vim.keymap.set({ "n", "x" }, "<Leader>ae", function() vsc.action("inlineChat.start", { count = 1 }) end)
vim.keymap.set(
  { "n", "x" },
  ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "r",
  function() vsc.action("git.revertSelectedRanges", { count = 1 }) end
)
vim.keymap.set({ "n", "x" }, "<Leader>gr", function() vsc.action("git.revertSelectedRanges", { count = 1 }) end)
vim.keymap.set({ "n", "x" }, "<Leader>gs", function() vsc.action("git.stageSelectedRanges", { count = 1 }) end)
vim.keymap.set({ "n", "x" }, "<Leader>gu", function() vsc.action("git.unstageSelectedRanges", { count = 1 }) end)
vim.keymap.set({ "n", "x" }, "]g", function()
  vsc.action "workbench.action.editor.nextChange"
  vsc.action "workbench.action.compareEditor.nextChange"
end)
vim.keymap.set({ "n", "x" }, "[g", function()
  vsc.action "workbench.action.editor.previousChange"
  vsc.action "workbench.action.compareEditor.previousChange"
end)
vim.keymap.set("n", "<Leader>gR", function() vsc.action("git.clean", { count = 1 }) end)
vim.keymap.set("n", "<Leader>gS", function()
  vsc.action("git.stageFile", { count = 1 })
  vsc.action("git.stage", { count = 1 })
end)
vim.keymap.set("n", "<Leader>gU", function()
  vsc.action("git.unstage", { count = 1 })
  vsc.action("git.unstageFile", { count = 1 })
end)
vim.keymap.set({ "n", "v" }, "<Leader>gp", function() vsc.action "editor.action.dirtydiff.next" end)
vim.keymap.set({ "n", "v" }, "<Leader>]g", function() vsc.action "editor.action.dirtydiff.next" end)
vim.keymap.set({ "n", "v" }, "<Leader>[g", function() vsc.action "editor.action.dirtydiff.previous" end)
vim.keymap.set("n", "<Leader>gC", function() vsc.action "merge-conflict.accept.all-current" end)
vim.keymap.set("n", "<Leader>gI", function() vsc.action "merge-conflict.accept.all-incoming" end)
vim.keymap.set("n", "<Leader>gB", function() vsc.action "merge-conflict.accept.all-both" end)
vim.keymap.set("n", "<Leader>gc", function() vsc.action "merge-conflict.accept.current" end)
vim.keymap.set("n", "<Leader>gi", function() vsc.action "merge-conflict.accept.incoming" end)
vim.keymap.set("n", "<Leader>gb", function() vsc.action "merge-conflict.accept.both" end)
vim.keymap.set("v", "<Leader>ga", function() vsc.action "merge-conflict.accept.selection" end)
vim.keymap.set({ "n", "v" }, "]x", function() vsc.action "merge-conflict.next" end)
vim.keymap.set({ "n", "v" }, "[x", function() vsc.action "merge-conflict.previous" end)
vim.keymap.set({ "n", "v" }, "<Leader>]x", function() vsc.action "merge.goToNextUnhandledConflict" end)
vim.keymap.set({ "n", "v" }, "<Leader>[x", function() vsc.action "merge.goToPreviousUnhandledConflict" end)
vim.keymap.set({ "n", "v" }, "]d", function() vsc.action "editor.action.marker.next" end)
vim.keymap.set({ "n", "v" }, "[d", function() vsc.action "editor.action.marker.prev" end)
vim.keymap.set("n", "<Leader>]d", function() vsc.action "editor.action.marker.nextInFiles" end)
vim.keymap.set("n", "<Leader>[d", function() vsc.action "editor.action.marker.prevInFiles" end)
vim.keymap.set({ "n", "v" }, "]b", function() go_to_breakpoint "next" end)
vim.keymap.set({ "n", "v" }, "[b", function() go_to_breakpoint "previous" end)
vim.keymap.set("n", "<Leader>m", function() vsc.action "bookmarks.toggle" end)
vim.keymap.set("n", "<Leader>M", function() vsc.action "bookmarks.listFromAllFiles" end)
vim.keymap.set("n", "<Leader>B", function() vsc.action "editor.debug.action.toggleBreakpoint" end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "]", function() vsc.action "editor.action.indentLines" end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "[", function() vsc.action "editor.action.outdentLines" end)
vim.keymap.set({ "n", "x" }, "<Leader>un", function() vsc.action "notifications.hideToasts" end)
vim.keymap.set(
  "n",
  "<Leader>*",
  function()
    vsc.action("workbench.action.findInFiles", {
      args = { { query = vim.fn.expand "<cword>" } },
      count = 1,
    })
  end
)
vim.keymap.set(
  "x",
  "<Leader>*",
  function()
    vsc.action("workbench.action.findInFiles", {
      args = { { query = vsc.get_visual_selection() } },
      count = 1,
    })
  end
)
vim.keymap.set("n", "<leader>/", function() vsc.action("workbench.action.findInFiles", { count = 1 }) end)
vim.keymap.set({ "n", "x" }, "za", function() vsc.action "editor.toggleFold" end)
vim.keymap.set({ "n", "x" }, "zR", function() vsc.action "editor.unfoldAll" end)
vim.keymap.set({ "n", "x" }, "zM", function() vsc.action "editor.foldAll" end)
vim.keymap.set({ "n", "x" }, "zo", function() vsc.action "editor.unfold" end)
vim.keymap.set({ "n", "x" }, "zO", function() vsc.action "editor.unfoldRecursively" end)
vim.keymap.set({ "n", "x" }, "zc", function() vsc.action "editor.fold" end)
vim.keymap.set({ "n", "x" }, "zC", function() vsc.action "editor.foldRecursively" end)
vim.keymap.set({ "n", "x" }, "z1", function() vsc.action "editor.foldLevel1" end)
vim.keymap.set({ "n", "x" }, "z2", function() vsc.action "editor.foldLevel2" end)
vim.keymap.set({ "n", "x" }, "z3", function() vsc.action "editor.foldLevel3" end)
vim.keymap.set({ "n", "x" }, "z4", function() vsc.action "editor.foldLevel4" end)
vim.keymap.set({ "n", "x" }, "z5", function() vsc.action "editor.foldLevel5" end)
vim.keymap.set({ "n", "x" }, "z6", function() vsc.action "editor.foldLevel6" end)
vim.keymap.set({ "n", "x" }, "z7", function() vsc.action "editor.foldLevel7" end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "1", function() vsc.action "editor.foldLevel1" end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "2", function() vsc.action "editor.foldLevel2" end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "3", function() vsc.action "editor.foldLevel3" end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "4", function() vsc.action "editor.foldLevel4" end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "5", function() vsc.action "editor.foldLevel5" end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "6", function() vsc.action "editor.foldLevel6" end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "7", function() vsc.action "editor.foldLevel7" end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "k" .. ctrl_cmd_lhs ",", function()
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
end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "k" .. ctrl_cmd_lhs ".", function()
  vsc.call "editor.removeManualFoldingRanges"
  return "<esc>"
end, { expr = true })
vim.keymap.set({ "n", "x" }, "zV", function() vsc.action "editor.foldAllExcept" end)
vim.keymap.set({ "n", "x" }, "zX", function() vsc.action "editor.removeManualFoldingRanges" end)
vim.keymap.set({ "n", "x" }, "]z", function() vsc.action "editor.gotoNextFold" end)
vim.keymap.set({ "n", "x" }, "[z", function() vsc.action "editor.gotoPreviousFold" end)
vim.keymap.set("x", ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "[", function() vsc.action "editor.foldRecursively" end)
vim.keymap.set("x", ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "]", function() vsc.action "editor.unfoldRecursively" end)
vim.keymap.set("x", ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "-", function() vsc.action "editor.foldAllExcept" end)
vim.keymap.set("x", ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "=", function() vsc.action "editor.unfoldAllExcept" end)
vim.keymap.set("x", "zx", function()
  vsc.call "editor.createFoldingRangeFromSelection"
  return "<esc>"
end, { expr = true })
vim.keymap.set("v", "<C-o>", "<Cmd>call VSCodeNotify('workbench.action.navigateBack')<CR>")
vim.keymap.set("v", "<C-i>", "<Cmd>call VSCodeNotify('workbench.action.navigateForward')<CR>")
vim.keymap.set("n", "<Leader>`.", "`.")
vim.keymap.set("n", "`.", "<Cmd>call VSCodeNotify('workbench.action.navigateToLastEditLocation')<CR>")
vim.keymap.set("n", "<Leader>g;", "g;")
vim.keymap.set("n", "<Leader>g,", "g,")
vim.keymap.set("n", "g;", "<Cmd>call VSCodeNotify('workbench.action.navigateBackInEditLocations')<CR>")
vim.keymap.set("n", "g,", "<Cmd>call VSCodeNotify('workbench.action.navigateForwardInEditLocations')<CR>")
vim.keymap.set("n", "gd", function() vsc.go_to_definition_marked "revealDefinition" end)
vim.keymap.set("n", "<Leader>gd", function() vsc.go_to_definition_marked "goToTypeDefinition" end)
vim.keymap.set("n", "<F12>", function() vsc.go_to_definition_marked "revealDefinition" end)
vim.keymap.set("n", "gf", function() vsc.go_to_definition_marked "revealDeclaration" end)
vim.keymap.set("n", "<C-]>", function() vsc.go_to_definition_marked "revealDefinition" end)
vim.keymap.set("n", "gO", function() vsc.action_marked("workbench.action.gotoSymbol", { count = 1 }) end)
vim.keymap.set("n", ctrl_cmd_lhs "O", function() vsc.action_marked("workbench.action.gotoSymbol", { count = 1 }) end)
vim.keymap.set("n", "gF", function() vsc.action_marked("editor.action.peekDeclaration", { count = 1 }) end)
vim.keymap.set("n", "<S-F12>", function() vsc.action_marked("editor.action.goToReferences", { count = 1 }) end)
vim.keymap.set("n", "gH", function() vsc.action_marked("editor.action.referenceSearch.trigger", { count = 1 }) end)
vim.keymap.set(
  "n",
  ctrl_cmd_lhs "S-F12",
  function() vsc.action_marked("editor.action.peekImplementation", { count = 1 }) end
)
vim.keymap.set("n", "<M-S-F12>", function() vsc.action_marked("references-view.findReferences", { count = 1 }) end)
vim.keymap.set("n", "gD", function() vsc.action_marked("editor.action.peekDefinition", { count = 1 }) end)
vim.keymap.set("n", "<M-F12>", function() vsc.action_marked("editor.action.peekDefinition", { count = 1 }) end)
vim.keymap.set(
  "n",
  ctrl_cmd_lhs "F12",
  function() vsc.action_marked("editor.action.goToImplementation", { count = 1 }) end
)
vim.keymap.set("n", ctrl_cmd_lhs ".", "<Cmd>call VSCodeCall('editor.action.quickFix')<CR>")
vim.keymap.set("n", "gx", function() vsc.action("editor.action.openLink", { count = 1 }) end)
vim.keymap.set("n", "<Leader>o", function() vsc.action("workbench.action.showOutputChannels", { count = 1 }) end)
vim.keymap.set("n", "<Leader>li", function() vsc.action("workbench.action.showOutputChannels", { count = 1 }) end)
vim.keymap.set("n", "<Leader>Ma", "<Cmd>call VSCodeNotify('workbench.action.tasks.runTask')<CR>")
vim.keymap.set("n", "<Leader>Mr", "<Cmd>call VSCodeNotify('workbench.action.tasks.runTask')<CR>")
vim.keymap.set("n", "<Leader>uc", "<Cmd>call VSCodeNotify('workbench.action.toggleCenteredLayout')<CR>")
vim.keymap.set(
  "n",
  "<Leader>uT",
  function()
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
)
vim.keymap.set({ "n", "x", "o" }, "[;", function()
  vsc.action("editor.action.focusStickyScroll", {
    callback = function(err)
      if not err then vsc.action "editor.action.goToFocusedStickyScrollLine" end
    end,
  })
end)
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "z", "<Cmd>call VSCodeNotify('undo')<CR>")
vim.keymap.set({ "n", "x" }, ctrl_cmd_lhs "Z", "<Cmd>call VSCodeNotify('redo')<CR>")
vim.keymap.set("n", ctrl_cmd_lhs "R", function()
  vim.api.nvim_feedkeys("i", "m", false)
  vsc.action("editor.action.showSnippets", { count = 1 })
end)
vim.keymap.set(
  "x",
  ctrl_cmd_lhs "R",
  function() vsc.action_insert_selection("editor.action.showSnippets", { count = 1 }) end
)
vim.keymap.set(
  "x",
  ctrl_cmd_lhs ".",
  function() vsc.action_insert_selection("editor.action.quickFix", { count = 1 }) end
)
vim.keymap.set("n", "<C-S-R>", function() vsc.action("editor.action.refactor", { count = 1 }) end)
vim.keymap.set("x", "<C-S-R>", function() vsc.action_insert_selection("editor.action.refactor", { count = 1 }) end)
vim.keymap.set(
  "x",
  "<M-S-s>",
  function() vsc.action_insert_selection("editor.action.surroundWithSnippet", { count = 1 }) end
)
vim.keymap.set("x", "<M-T>", function() vsc.action_insert_selection("surround.with", { count = 1 }) end)
vim.keymap.set({ "n", "x" }, "<M-F>", "<Cmd>call VSCodeCall('editor.action.formatDocument')<CR>")
vim.keymap.set(
  { "n", "x" },
  ctrl_cmd_lhs "k" .. ctrl_cmd_lhs "f",
  "<Cmd>call VSCodeCall('editor.action.formatSelection', 1)<CR>"
)
vim.keymap.set({ "n", "x" }, "<M-l>", function() vsc.action "editor.action.indentLines" end)
vim.keymap.set({ "n", "x" }, "<M-h>", function() vsc.action "editor.action.outdentLines" end)
vim.keymap.set({ "n", "x" }, "<M-D>", function() vsc.action "abracadabra.moveStatementDown" end)
vim.keymap.set({ "n", "x" }, "<M-U>", function() vsc.action "abracadabra.moveStatementUp" end)
vim.keymap.set("n", harpoon_prefix .. "a", function() vsc.action("vscode-harpoon.addEditor", { count = 1 }) end)
vim.keymap.set("n", harpoon_prefix .. "d", function() vsc.action("vscode-harpoon.editorQuickPick", { count = 1 }) end)
vim.keymap.set("n", harpoon_prefix .. "s", function() vsc.action("vscode-harpoon.editEditors", { count = 1 }) end)
vim.keymap.set("n", "<M-0>", function() vsc.action("vscode-harpoon.editEditors", { count = 1 }) end)
vim.keymap.set("n", "<M-1>", function() vsc.action("vscode-harpoon.gotoEditor1", { count = 1 }) end)
vim.keymap.set("n", "<M-2>", function() vsc.action("vscode-harpoon.gotoEditor2", { count = 1 }) end)
vim.keymap.set("n", "<M-3>", function() vsc.action("vscode-harpoon.gotoEditor3", { count = 1 }) end)
vim.keymap.set("n", "<M-4>", function() vsc.action("vscode-harpoon.gotoEditor4", { count = 1 }) end)
vim.keymap.set("n", "<M-5>", function() vsc.action("vscode-harpoon.gotoEditor5", { count = 1 }) end)
vim.keymap.set("n", "<M-6>", function() vsc.action("vscode-harpoon.gotoEditor6", { count = 1 }) end)
vim.keymap.set("n", "<M-7>", function() vsc.action("vscode-harpoon.gotoEditor7", { count = 1 }) end)
vim.keymap.set("n", "<M-8>", function() vsc.action("vscode-harpoon.gotoEditor8", { count = 1 }) end)
vim.keymap.set("n", "<M-9>", function() vsc.action("vscode-harpoon.gotoEditor9", { count = 1 }) end)
vim.keymap.set("n", "<Leader>W", function() vsc.action "workbench.action.files.saveWithoutFormatting" end)
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "ол", "<Esc>")
vim.keymap.set("i", "<C-g>", "<Esc>")
