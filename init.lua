-- init.lua
--
-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = { 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.nvim', mini_path }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })


-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Safely execute immediately
now(function()
  -- Set leader key
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "
  -- Load Colorscheme
  vim.cmd('colorscheme randomhue')
  -- Import Options
  require('opts')
end)

now(function() add({ source = 'neovim/nvim-lspconfig',})
  require('lsp')
end)

later(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    -- Use 'master' while monitoring updates in 'main'
    checkout = 'master',
    monitor = 'main',
    -- Perform action after every checkout
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  require('ts')
end)

-- Keybindings
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Example keybindings with custom options
map('n', '<leader>q', ':q<CR>', { silent = false })                  -- Quit, not silent
map('n', '<leader>c', ':bdelete<CR>', { noremap = true, silent = true }) -- Close buffer

-- Autocommand to clear search highlighting when cursor moves or entering insert mode
vim.api.nvim_create_augroup('ClearSearchHL', { clear = true })
vim.api.nvim_create_autocmd('CursorMoved', {
  group = 'ClearSearchHL',
  callback = function()
    vim.cmd('nohlsearch')
  end
})
vim.api.nvim_create_autocmd('InsertEnter', {
  group = 'ClearSearchHL',
  callback = function()
    vim.cmd('nohlsearch')
  end
})
