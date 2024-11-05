local M = {}

M.DATA_DIR = vim.fn.stdpath "data" .. "/zoxide"
M.DATA_DIR_VAR_NAME = "_ZO_DATA_DIR"

local zoxide_command_env = { [M.DATA_DIR_VAR_NAME] = M.DATA_DIR }

---@param dir string
function M.remove(dir) return vim.system({ "zoxide", "remove", dir }, { env = zoxide_command_env }) end

---@param dir string
function M.add(dir) return vim.system({ "zoxide", "add", dir }, { env = zoxide_command_env }) end

return M
