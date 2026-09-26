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

-- Yank absolute path to the system clipboard
vim.keymap.set('n', '<leader>cp', function()
    local path = vim.fn.expand('%:p')
    vim.fn.setreg('+', path)
    vim.notify("Copied path: " .. path, vim.log.levels.INFO)
end, { desc = "Copy absolute file path" })
