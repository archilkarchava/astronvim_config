local M = {}

function M.chord_prefix() return require("util.platform").is_macos() and "<D-k>" or "<C-k>" end

---@param keymap string
function M.normalize_keymap(keymap)
  local prefix = require("util.platform").is_macos() and "<D-" or "<C-"
  return keymap:gsub("<D%-", prefix)
end

return M
