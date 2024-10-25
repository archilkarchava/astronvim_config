local M = {}

function M.is_macos() return vim.uv.os_uname().sysname == "Darwin" end

return M
