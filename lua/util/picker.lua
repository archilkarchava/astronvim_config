local builtins = require "telescope.builtin"

local M = {}

local picker = nil

function M.get_picker()
  if picker then return picker end
  local astrocore = require "astrocore"
  local is_snacks_available = astrocore.is_available "snacks.nvim"
  local is_telescope_available = astrocore.is_available "telescope.nvim"

  if not is_snacks_available then
    picker = is_telescope_available and "telescope" or "native"
    return picker
  end

  local snacks_opts = astrocore.plugin_opts "snacks.nvim"
  local is_snacks_picker_enabled = vim.tbl_get(snacks_opts, "picker", "ui_select")

  picker = is_snacks_picker_enabled and "snacks" or (is_telescope_available and "telescope" or "native")
  return picker
end

function M.grep_last_search(opts)
  opts = opts or {}

  -- \<getreg\>\C
  -- -> Subs out the search things
  local word = vim.fn.getreg("/"):gsub("\\<", ""):gsub("\\>", ""):gsub("\\C", ""):gsub("^\\[vV]", "", 1)

  opts.path_display = opts.path_display or { "shorten_path" }
  opts.search = word
  opts.prompt_title = opts.prompt_title or ("Last Search Grep (" .. word:gsub("\n", "\\n") .. ")")

  builtins.grep_string(opts)
end

return M
