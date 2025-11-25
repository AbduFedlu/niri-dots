-------------------------------keybinds-----------------------------------

vim.keymap.set('n', '<S-F>', ':NvimTreeToggle<CR>', { noremap = true, silent = true } )
vim.keymap.set('n', '<C-a>', 'ggVG', { noremap = true, silent = true })
-- Copy selection to system clipboard
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true, silent = true })  -- visual mode
vim.keymap.set('n', '<C-c>', '"+yy', { noremap = true, silent = true }) -- copy current line

-- Cut selection to system clipboard
vim.keymap.set('v', '<C-x>', '"+d', { noremap = true, silent = true })  -- visual mode
vim.keymap.set('n', '<C-x>', '"+dd', { noremap = true, silent = true }) -- cut current line

-- Paste from system clipboard
vim.keymap.set('n', '<C-p>', '"+p', { noremap = true, silent = true })
vim.keymap.set('v', '<C-p>', '"+p', { noremap = true, silent = true })

-- Undo with Ctrl+Z
vim.keymap.set('n', '<C-z>', 'u', { noremap = true, silent = true })
vim.keymap.set('i', '<C-z>', '<Esc>u', { noremap = true, silent = true })

-- Redo with Ctrl+Y
vim.keymap.set('n', '<C-y>', '<C-r>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-z>', '<Esc>u', { noremap = true, silent = true })

-- Ctrl+S save
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true, silent = true })

-- Ctrl+Q quit
vim.keymap.set('n', '<C-q>', ':q<CR>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-q>', '<Esc>:q<CR>', { noremap = true, silent = true })



-------------------------------matugen------------------------------------

local function source_matugen()
  local path = os.getenv("HOME") .. "/.config/nvim/generated.lua"
  local f, err = io.open(path, "r")
  if not f then
    vim.cmd('colorscheme base16-catppuccin-mocha')
  else
    dofile(path)
    io.close(f)
  end
end

source_matugen()


vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function()
    source_matugen()
    dofile(os.getenv("HOME") .. '/.config/nvim/plugins/lualine.lua')
    vim.api.nvim_set_hl(0, "Comment", { italic = true })
  end,
})

------------------------------packer--------------------------------------

require('nvim-tree').setup({})

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'nvim-tree/nvim-tree.lua',
    requires = 'nvim-tree/nvim-web-devicons'
  }
  
  use {
  'nvim-lualine/lualine.nvim',
  requires = { 'nvim-tree/nvim-web-devicons', opt = true }
}

  use 'RRethy/nvim-base16'
end)
----------------------------------------------------------------------


