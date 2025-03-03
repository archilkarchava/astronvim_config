local M = {}

local bit = require "bit"

---Convert a hexadecimal color string to its numerical representation.
---@param hex_str string Hexadecimal color string (e.g., "#RRGGBB" or "RRGGBB").
---@return number The numerical representation of the hex color, or nil if the input is invalid.
function M.hex_to_number(hex_str)
  -- Remove the '#' if present
  local str = hex_str:gsub("#", "")
  -- Convert hex string to number
  return tonumber(str, 16)
end

--- Returns a table containing the RGB values encoded inside 24 least
--- significant bits of the number @rgb_24bit
---
---@param rgb_24bit number 24-bit RGB value
---@return {r: integer, g: integer, b: integer} with keys 'r', 'g', 'b' in [0,255]
function M.decode_24bit_rgb(rgb_24bit)
  vim.validate { rgb_24bit = { rgb_24bit, "n", true } }
  local r = bit.band(bit.rshift(rgb_24bit, 16), 255)
  local g = bit.band(bit.rshift(rgb_24bit, 8), 255)
  local b = bit.band(rgb_24bit, 255)
  return { r = r, g = g, b = b }
end

---@param attr integer
---@param percent integer
function M.alter(attr, percent) return math.floor(attr * (100 + percent) / 100) end

---@source https://stackoverflow.com/q/5560248
---@see https://stackoverflow.com/a/37797380
---Lighten a specified hex color
---@param color number|string
---@param percent number
---@param background "dark"|"light"?
---@return string
function M.shade_color(color, percent, background)
  -- Convert hex string to number if necessary
  if type(color) == "string" then color = M.hex_to_number(color) end
  background = background or vim.opt.background:get()
  percent = background == "light" and percent / 5 or percent
  local rgb = M.decode_24bit_rgb(color)
  if not rgb.r or not rgb.g or not rgb.b then return "NONE" end
  local r, g, b = M.alter(rgb.r, percent), M.alter(rgb.g, percent), M.alter(rgb.b, percent)
  r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
  return string.format("#%02x%02x%02x", r, g, b)
end

return M
