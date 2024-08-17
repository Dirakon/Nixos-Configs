vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions";

require("auto-session").setup {
  auto_session_enable_last_session = vim.loop.cwd() == vim.loop.os_homedir(),
  args_allow_single_directory = true,
  auto_session_enabled = true,
  auto_save_enabled = true,
  auto_restore_enabled = true,
}


-- so much for "auto" session. Why the hell does it not work automatically?
vim.api.nvim_create_autocmd({ "ExitPre" }, {
	callback = function()
            vim.cmd('SessionSave');
	end,
})
vim.api.nvim_create_autocmd({ "VimEnter" }, {
	callback = function()
            vim.cmd('SessionRestore');
	end,
})
