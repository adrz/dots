-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
--
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without copying" })
vim.keymap.set({ "n", "v" }, "<leader>D", '"_D', { desc = "Delete line without copying" })
vim.opt.clipboard = "unnamedplus"
--vim.g.autoformat = false
--
-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--     ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
--   },
--   paste = {
--     ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
--   },
-- }
--
-- -- Optional: Sync the unnamed register so standard 'y' copies to system clipboard
-- vim.opt.clipboard = "unnamedplus"
