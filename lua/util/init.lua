-- Define the util module
local M = {}

function M.is_kitty() return vim.env.KITTY_PID ~= nil end

return M
