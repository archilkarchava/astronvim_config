local M = {}

M.DATA_DIR = vim.env._ZO_DATA_PROJECTS_DIR or vim.fn.stdpath "data" .. "/zoxide"
M.DATA_DIR_VAR_NAME = "_ZO_DATA_DIR"

local zoxide_command_env = { [M.DATA_DIR_VAR_NAME] = M.DATA_DIR }

--- @param cmd (string[]) Zoxide command to execute
local exec_zoxide = function(cmd)
  local system_cmd = vim.list_extend({ "zoxide" }, cmd)
  return vim.system(system_cmd, { env = zoxide_command_env })
end

---@param dir string
function M.remove(dir) return exec_zoxide { "remove", dir } end

---@param dir string
function M.add(dir) return exec_zoxide { "add", dir } end

return M
