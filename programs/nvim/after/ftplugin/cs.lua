local omnisharp_extended = require('omnisharp_extended')


vim.keymap.set('n', 'gr', omnisharp_extended.telescope_lsp_references, { desc = '[G]oto [R]eferences' })
vim.keymap.set('n', 'gt', omnisharp_extended.telescope_lsp_type_definition, { desc = '[G]oto [T]ype definitions' })
vim.keymap.set('n', 'gd', omnisharp_extended.telescope_lsp_definition, { desc = '[G]oto [D]efinitions' })
vim.keymap.set('n', 'gi', omnisharp_extended.telescope_lsp_implementation, { desc = '[G]oto [I]mplementation' })
