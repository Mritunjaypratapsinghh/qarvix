-- Qarvix Neovim Config
vim.g.mapleader = " "

-- Options
local o = vim.opt
o.number = true
o.relativenumber = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true
o.wrap = false
o.cursorline = true
o.termguicolors = true
o.signcolumn = "yes"
o.scrolloff = 8
o.updatetime = 250
o.clipboard = "unnamedplus"
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.mouse = "a"

-- Keymaps
local k = vim.keymap.set
k("n", "<leader>w", ":w<CR>", { desc = "Save" })
k("n", "<leader>q", ":q<CR>", { desc = "Quit" })
k("n", "<leader>e", ":Ex<CR>", { desc = "Explorer" })
k("n", "<Esc>", ":noh<CR>", { desc = "Clear search" })
k("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
k("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
k("n", "<C-d>", "<C-d>zz")
k("n", "<C-u>", "<C-u>zz")

-- Tokyo Night colors (minimal)
vim.cmd([[
  highlight Normal guibg=#1a1b26 guifg=#c0caf5
  highlight CursorLine guibg=#292e42
  highlight LineNr guifg=#565f89
  highlight CursorLineNr guifg=#7aa2f7
  highlight Visual guibg=#33467c
  highlight Comment guifg=#565f89 gui=italic
  highlight String guifg=#9ece6a
  highlight Keyword guifg=#bb9af7
  highlight Function guifg=#7aa2f7
  highlight Number guifg=#ff9e64
  highlight StatusLine guibg=#1a1b26 guifg=#7aa2f7
  highlight Pmenu guibg=#1a1b26 guifg=#c0caf5
  highlight PmenuSel guibg=#33467c
  highlight SignColumn guibg=#1a1b26
]])
