local M = {}

function M.is_kitty() return vim.env.KITTY_PID ~= nil end

---Changes the layout of the Kitty terminal.
---@param layout "fat" | "grid" | "horizontal" | "splits" | "stack" | "tall" | "vertical"
local function kitty_goto_layout(layout) return vim.system { "kitty", "@", "goto-layout", layout } end

---@param opt? { direction?: "vertical" | "horizontal" }
function M.toggle_terminal(opt)
  vim.validate {
    opt = { opt, "table", true },
  }
  if opt == nil then opt = {} end
  vim.validate {
    ["opt.direction"] = {
      opt.direction,
      function(direction) return direction == nil or direction == "vertical" or direction == "horizontal" end,
      "direction value",
    },
  }
  local direction = opt.direction or "horizontal"
  local location = direction == "vertical" and "vsplit" or "hsplit"
  local term_window_id_var = "kitty_toggle_" .. location .. "_term_window_id"
  local is_term_window_exists = false
  if vim.g[term_window_id_var] ~= nil then
    local find_term_window_result =
      vim.system({ "kitty", "@", "ls", "--match", "id:" .. vim.g[term_window_id_var] }):wait()
    is_term_window_exists = find_term_window_result.code == 0
  end
  if is_term_window_exists then
    vim.system { "kitty", "@", "focus-window", "--match", "id:" .. vim.g[term_window_id_var] }
    kitty_goto_layout "splits"
    return
  end
  kitty_goto_layout("splits"):wait()
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
  vim.g[term_window_id_var] = window_id
end

return M
