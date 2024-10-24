-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

vim.api.nvim_create_user_command("CopyPath", function()
  local path = vim.fn.expand "%:p"
  vim.fn.setreg("+", path)
  vim.notify('Copied "' .. path .. '" to the clipboard.')
end, {})

vim.api.nvim_create_user_command("CopyRelPath", function()
  local path = vim.fn.expand "%:~:."
  vim.fn.setreg("+", path)
  vim.notify('Copied "' .. path .. '" to the clipboard.')
end, {})

-- Set up custom filetypes
-- vim.filetype.add {
--   extension = {
--     foo = "fooscript",
--   },
--   filename = {
--     ["Foofile"] = "fooscript",
--   },
--   pattern = {
--     ["~/%.config/foo/.*"] = "fooscript",
--   },
-- }
