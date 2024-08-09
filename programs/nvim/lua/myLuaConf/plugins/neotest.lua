require("neotest").setup({
  adapters = {
    require("neotest-dotnet")({
      dap = { justMyCode = false },
    }),
  },
})

vim.keymap.set('n', '<leader>Tr', (function() require("neotest").run.run() end), { desc = 'Neo[T]est - [R]un closest' })
vim.keymap.set('n', '<leader>TR', (function() require("neotest").run.run(vim.fn.expand("%")) end), { desc = 'Neo[T]est - [R]un all in file' })
vim.keymap.set('n', '<leader>Ts', (function() require("neotest").run.stop() end), { desc = 'Neo[T]est - [S]top' })
vim.keymap.set('n', '<leader>Td', (function() require("neotest").run.run({strategy = "dap"}) end), { desc = 'Neo[T]est - [D]ebug closest' })
