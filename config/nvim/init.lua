-- Qarvix Neovim Config (LSP + Treesitter)
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
k("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move down" })
k("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move up" })
k("n", "<C-d>", "<C-d>zz")
k("n", "<C-u>", "<C-u>zz")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
    -- Colorscheme
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            require("tokyonight").setup({ style = "night", transparent = true })
            vim.cmd.colorscheme("tokyonight-night")
        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "rust", "python", "javascript", "typescript",
                    "go", "bash", "json", "toml", "yaml", "html", "css", "markdown" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "rust_analyzer", "lua_ls", "pyright", "ts_ls" },
            })
            local lsp = require("lspconfig")
            local on_attach = function(_, bufnr)
                local b = function(mode, key, cmd)
                    vim.keymap.set(mode, key, cmd, { buffer = bufnr })
                end
                b("n", "gd", vim.lsp.buf.definition)
                b("n", "gr", vim.lsp.buf.references)
                b("n", "K", vim.lsp.buf.hover)
                b("n", "<leader>ca", vim.lsp.buf.code_action)
                b("n", "<leader>rn", vim.lsp.buf.rename)
                b("n", "<leader>d", vim.diagnostic.open_float)
            end
            local servers = { "rust_analyzer", "lua_ls", "pyright", "ts_ls" }
            for _, s in ipairs(servers) do
                lsp[s].setup({ on_attach = on_attach })
            end
        end,
    },

    -- Autocomplete
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                }),
                sources = { { name = "nvim_lsp" }, { name = "luasnip" }, { name = "buffer" }, { name = "path" } },
            })
        end,
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        },
    },

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        config = function() require("gitsigns").setup() end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("lualine").setup({ options = { theme = "tokyonight" } })
        end,
    },
})
