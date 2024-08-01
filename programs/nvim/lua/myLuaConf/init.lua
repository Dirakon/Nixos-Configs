require("myLuaConf.plugins")
require("myLuaConf.LSPs")


-- Some general remappings (TODO: different files?)



vim.keymap.set('n', '<leader>x', ':bd<CR>', { desc = 'close buffer' })
vim.keymap.set('n', '<leader>d', ':Oil<CR>', { desc = '[D]irectory explorer' })
-- vim.keymap.set('n', '<leader>X', ':close<CR>', { desc = 'close file' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })


local pos_equal = function(p1, p2)
	local r1, c1 = unpack(p1)
	local r2, c2 = unpack(p2)
	return r1 == r2 and c1 == c2
end

local goto_next_diagnostic_by_severity = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
	local pos2 = vim.api.nvim_win_get_cursor(0)
	if (pos_equal(pos, pos2)) then
		vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN, wrap = true })
		local pos3 = vim.api.nvim_win_get_cursor(0)
		if (pos_equal(pos, pos3)) then
			vim.diagnostic.goto_next({ wrap = true })
		end
	end
end

local goto_prev_diagnostic_by_severity = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
	local pos2 = vim.api.nvim_win_get_cursor(0)
	if (pos_equal(pos, pos2)) then
		vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN, wrap = true })
		local pos3 = vim.api.nvim_win_get_cursor(0)
		if (pos_equal(pos, pos3)) then
			vim.diagnostic.goto_prev({ wrap = true })
		end
	end
end

local goto_next_diagnostic = function()
	vim.diagnostic.goto_next({ wrap = true })
end

local goto_prev_diagnostic = function()
	vim.diagnostic.goto_prev({ wrap = true })
end

-- Some diagnostic navigation override -> https://github.com/neovim/neovim/discussions/25588
vim.keymap.set("n", '[d', goto_prev_diagnostic_by_severity, { noremap = true, desc = 'Jump to previous [D]iagnostic (by severity)' })
vim.keymap.set("n", ']d', goto_next_diagnostic_by_severity, { noremap = true, desc = 'Jump to next [D]iagnostic (by severity)' })
vim.keymap.set("n", '[D', goto_prev_diagnostic, { noremap = true, desc = 'Jump to previous [D]iagnostic (all)' })
vim.keymap.set("n", ']D', goto_next_diagnostic, { noremap = true, desc = 'Jump to next [D]iagnostic (all)' })

--if os.getenv('WAYLAND_DISPLAY') and vim.fn.exepath('wl-copy') ~= "" then
--	vim.g.clipboard = {
--		name = 'wl-clipboard',
--		copy = {
--			['+'] = 'wl-copy',
--			['*'] = 'wl-copy',
--		},
--		paste = {
--			['+'] = 'wl-paste',
--			['*'] = 'wl-paste',
--		},
--		cache_enabled = 1,
--	}
--end


-- kickstart.nvim starts you with this.
-- But it constantly clobbers your system clipboard whenever you delete anything.

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

-- You should instead use these keybindings so that they are still easy to use, but dont conflict
vim.keymap.set("n", '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({ "v", "x" }, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({ "n", "v", "x" }, '<leader>yy', '"+yy',
	{ noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({ "n", "v", "x" }, '<leader>Y', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({ "n", "v", "x" }, '<C-a>', 'gg0vG$', { noremap = true, silent = true, desc = 'Select all' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+',
	{ noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' })
vim.keymap.set("x", "<leader>P", '"_dP',
	{ noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' })

-- Some general settings (TODO: different files?)
vim.g.have_nerd_font = true

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true -- Every wrapped line will continue visually indented (same amount of space as the beginning of that line)

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes' -- git-like file changes and stuff

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')


-- Neovide
if vim.g.neovide then
	vim.g.neovide_transparency = 0.5
	vim.g.neovide_scale_factor = 0.8
end

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = '*',
})
