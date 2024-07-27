require('gitsigns').setup()
-- require('lazygit').setup() No setup needed?

vim.keymap.set('n', '<leader>g', ':LazyGit<CR>', { desc = '[G]it UI' })

