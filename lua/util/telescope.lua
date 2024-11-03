local builtins = require "telescope.builtin"

local M = {}

function M.grep_last_search(opts)
  opts = opts or {}

  -- \<getreg\>\C
  -- -> Subs out the search things
  local word = vim.fn.getreg("/"):gsub("\\<", ""):gsub("\\>", ""):gsub("\\C", ""):gsub("\\[vV]", "")

  opts.path_display = opts.path_display or { "shorten_path" }
  opts.word_match = "-w"
  opts.search = word
  opts.prompt_title = opts.prompt_title or ("Last Search Grep (" .. word:gsub("\n", "\\n") .. ")")

  builtins.grep_string(opts)
end

return M
