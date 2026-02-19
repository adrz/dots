-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", {
  noremap = true,
  silent = true,
  desc = "Ouvrir la fenêtre de diagnostic", -- Petite description, c'est une bonne pratique
})
