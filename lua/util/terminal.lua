local M = {}

function M.is_kitty() return vim.env.KITTY_PID ~= nil end

---@param location? "split" | "vsplit" | "hsplit"
function M.toggle_terminal(location)
  vim.validate {
    location = {
      location,
      function(loc) return loc == nil or loc == "split" or loc == "vsplit" or loc == "hsplit" end,
      "valid kitty terminal location",
    },
  }
  location = location or "hsplit"
  local is_term_window_exists = false
  if vim.g.kitty_toggle_term_window_id ~= nil then
    local find_term_window_result =
      vim.system({ "kitty", "@", "ls", "--match", "id:" .. vim.g.kitty_toggle_term_window_id }):wait()
    is_term_window_exists = find_term_window_result.code == 0
  end
  if is_term_window_exists then
    vim.system { "kitty", "@", "focus-window", "--match", "id:" .. vim.g.kitty_toggle_term_window_id }
  else
    local create_term_window_result = vim
      .system({
        "kitty",
        "@",
        "launch",
        "--location=" .. location,
        "--cwd=current",
        "--bias=30",
      }, { text = true })
      :wait()
    if create_term_window_result.stdout == nil or create_term_window_result.code ~= 0 then return end
    local window_id = tonumber(create_term_window_result.stdout:gsub("%s+", ""), 10)
    vim.g.kitty_toggle_term_window_id = window_id
  end
  vim.system { "kitty", "@", "goto-layout", "splits" }
end

return M
