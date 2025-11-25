-- ~/.config/nvim/lua/plugins/base16.lua
vim.cmd [[packadd base16.nvim]]  -- ensure plugin is installed

require('base16-colorscheme').setup({
  base00 = "0f111a",  -- replace with Matugen variables
  base01 = "1c1e26",
  base02 = "262730",
  base03 = "5c5f77",
  base04 = "b3b5c3",
  base05 = "c7c9d3",
  base06 = "e0e2ec",
  base07 = "f5f7ff",
  base08 = "f38ba8",
  base09 = "f8bd96",
  base0A = "fae3b0",
  base0B = "abe9b3",
  base0C = "89dceb",
  base0D = "74c7ec",
  base0E = "b4befe",
  base0F = "f5c2e7",
})

-- tweak highlights
vim.api.nvim_set_hl(0, 'Visual', { bg = '74c7ec', fg = '0f111a' })

