local M = {}

function M.is_macos() return vim.uv.os_uname().sysname == "Darwin" end

function M.is_windows() return vim.uv.os_uname().sysname == "Windows_NT" end

return M
