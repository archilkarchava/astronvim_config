local M = {}

function M.is_kitty() return vim.env.KITTY_PID ~= nil and not vim.g.neovide and not vim.g.vscode end

---@param args string|string[]
function M.kitty_set_colors(args)
  local cmd = { "kitty", "@", "set-colors" }
  if type(args) == "string" then args = { args } end
  cmd = vim.list_extend(cmd, args)
  return require("astrocore").cmd(cmd)
end

---@param background "dark"|"light"|"default"?
function M.kitty_set_theme(background)
  local cmd = {}
  if background == nil or background == "default" then table.insert(cmd, "--reset") end
  local is_dark_theme = background == "dark"
  local theme_path = vim.fn.expand(
    is_dark_theme and "$HOME/.config/kitty/themes/mocha-no-tabbar.conf"
      or "$HOME/.config/kitty/themes/latte-no-tabbar.conf"
  )
  table.insert(cmd, theme_path)
  return M.kitty_set_colors(cmd)
end

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

function M.get_lazygit_config_dir()
  if vim.g.lazygit_config_dir ~= nil then return vim.g.lazygit_config_dir end
  local lg_config_dir = require("astrocore").cmd({ "lazygit", "--print-config-dir" }, false)
  if not lg_config_dir then return end
  lg_config_dir = vim.split(lg_config_dir, "\n", { plain = true })[1]
  vim.g.lazygit_config_dir = lg_config_dir
  return lg_config_dir
end

function M.get_lazygit_config_file()
  if vim.g.lazygit_main_config_file == nil then vim.g.lazygit_main_config_file = vim.env.LG_CONFIG_FILE end
  local lg_config_dir = M.get_lazygit_config_dir()
  if lg_config_dir == nil then return vim.g.lazygit_main_config_file end
  vim.g.lazygit_main_config_file = vim.g.lazygit_main_config_file or lg_config_dir .. "/config.yml"
  vim.g.lazygit_dark_theme_config_file = vim.g.lazygit_dark_theme_config_file
    or lg_config_dir .. "/themes/catppuccin-mocha.yml"
  vim.g.lazygit_light_theme_config_file = vim.g.lazygit_light_theme_config_file
    or lg_config_dir .. "/themes/catppuccin-latte.yml"
  local lg_theme_config_file = vim.go.background == "dark" and vim.g.lazygit_dark_theme_config_file
    or vim.g.lazygit_light_theme_config_file
  if lg_theme_config_file == nil then return vim.g.lazygit_main_config_file end
  return vim.fs.normalize(vim.g.lazygit_main_config_file) .. "," .. vim.fs.normalize(lg_theme_config_file)
end

return M
