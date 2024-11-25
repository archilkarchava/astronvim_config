local M = {}

function M.is_kitty() return vim.env.KITTY_PID ~= nil and not vim.g.neovide and not vim.g.vscode end

--- @param action string
--- @param args string|string[]?
--- @param opts vim.SystemOpts? Options:
---   - cwd: (string) Set the current working directory for the sub-process.
---   - env: table<string,string> Set environment variables for the new process. Inherits the
---     current environment with `NVIM` set to |v:servername|.
---   - clear_env: (boolean) `env` defines the job environment exactly, instead of merging current
---     environment.
---   - stdin: (string|string[]|boolean) If `true`, then a pipe to stdin is opened and can be written
---     to via the `write()` method to SystemObj. If string or string[] then will be written to stdin
---     and closed. Defaults to `false`.
---   - stdout: (boolean|function)
---     Handle output from stdout. When passed as a function must have the signature `fun(err: string, data: string)`.
---     Defaults to `true`
---   - stderr: (boolean|function)
---     Handle output from stderr. When passed as a function must have the signature `fun(err: string, data: string)`.
---     Defaults to `true`.
---   - text: (boolean) Handle stdout and stderr as text. Replaces `\r\n` with `\n`.
---   - timeout: (integer) Run the command with a time limit. Upon timeout the process is sent the
---     TERM signal (15) and the exit code is set to 124.
---   - detach: (boolean) If true, spawn the child process in a detached state - this will make it
---     a process group leader, and will effectively enable the child to keep running after the
---     parent exits. Note that the child process will still keep the parent's event loop alive
---     unless the parent process calls |uv.unref()| on the child's process handle.
---
--- @param on_exit? fun(out: vim.SystemCompleted) Called when subprocess exits. When provided, the command runs
---   asynchronously. Receives SystemCompleted object, see return of SystemObj:wait().
function M.kitty_cmd(action, args, opts, on_exit)
  local cmd = { "kitty", "@", action }
  args = args or {}
  if type(args) == "string" then args = { args } end
  cmd = vim.list_extend(cmd, args)
  return vim.system(cmd, opts, on_exit)
end

---@param args string|string[]
function M.kitty_set_colors(args) return M.kitty_cmd("set-colors", args) end

---@param args string|string[]?
function M.kitty_get_colors(args) return M.kitty_cmd("get-colors", args) end

--- Returns all colors as a normalized string.
---@return string|nil Normalized colors string or nil if colors are not available.
local function kitty_get_all_colors_normalized_string()
  local colors = M.kitty_get_colors():wait().stdout
  if colors == nil then return nil end
  colors = colors:gsub("[ \t]+", "="):gsub("\n$", "")
  return colors
end

function M.kitty_get_all_colors_dict()
  local colors = kitty_get_all_colors_normalized_string()
  if colors == nil then return nil end
  ---@type table<string,string>
  local color_table = {}
  for _, line in ipairs(vim.split(colors, "\n", { plain = true })) do
    local key, value = unpack(vim.split(line, "=", { plain = true }))
    if key and value then color_table[key] = value end
  end
  return color_table
end

function M.kitty_get_all_colors_list()
  local colors = kitty_get_all_colors_normalized_string()
  if colors == nil then return nil end
  return vim.split(colors, "\n", { plain = true })
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
local function kitty_goto_layout(layout) return M.kitty_cmd("goto-layout", layout) end

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
    local find_term_window_result = M.kitty_cmd("ls", { "--match", "id:" .. vim.g[term_window_id_var] }):wait()
    is_term_window_exists = find_term_window_result.code == 0
  end
  if is_term_window_exists then
    M.kitty_cmd("focus-window", { "--match", "id:" .. vim.g[term_window_id_var] })
    kitty_goto_layout "splits"
    return
  end
  kitty_goto_layout("splits"):wait()
  local create_term_window_result = M.kitty_cmd("launch", {
    "--location=" .. location,
    "--cwd=current",
    "--bias=30",
  }, { text = true }):wait()
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
