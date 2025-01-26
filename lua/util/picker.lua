local M = {}

---@type "fzf" | "mini.pick" | "snacks" | "telescope" | string
M.picker = "snacks"

function M.grep_last_search(opts)
  opts = opts or {}

  -- \<getreg\>\C
  -- -> Subs out the search things
  local word = vim.fn.getreg("/"):gsub("\\<", ""):gsub("\\>", ""):gsub("\\C", ""):gsub("^\\[vV]", "", 1)

  opts.path_display = opts.path_display or { "shorten_path" }
  opts.search = word
  opts.prompt_title = opts.prompt_title or ("Last Search Grep (" .. word:gsub("\n", "\\n") .. ")")

  require("telescope.builtin").grep_string(opts)
end

return M
