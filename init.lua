-- ~/.config/nvim/init.lua
-- =============================
-- Bootstrap Lazy.nvim
-- =============================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================
-- Plugins
-- =============================
require("lazy").setup({
  -- Colorscheme
  { "folke/tokyonight.nvim" },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Autocomplete
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },

  -- File Explorer & Icons
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-tree/nvim-web-devicons" },

  -- Fuzzy Finder
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Autopairs
  { "windwp/nvim-autopairs" },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if ok then
        ts.setup({
          ensure_installed = { "c", "java", "cpp", "lua", "python", "javascript", "html", "css" },
          highlight = { enable = true, additional_vim_regex_highlighting = false },
          indent = { enable = true },
          autopairs = { enable = true },
          rainbow = { enable = true, extended_mode = true },
        })

        -- Optional: auto-install missing parsers
        local ts_install = require("nvim-treesitter.install")
        ts_install.update({ with_sync = true })
      end
    end,
  },
})

-- =============================
-- General settings
-- =============================
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

vim.cmd([[syntax on]])
vim.cmd([[filetype plugin indent on]])

-- =============================
-- Indentation settings (for C, Python, JS, Lua, etc.)
-- =============================
vim.opt.tabstop = 4        -- a tab character counts as 4 spaces
vim.opt.shiftwidth = 4     -- indentation commands use 4 spaces
vim.opt.softtabstop = 4    -- pressing Tab inserts 4 spaces
vim.opt.expandtab = true   -- use spaces instead of tabs
vim.opt.smartindent = true -- auto-indent for C-like languages

-- =============================
-- Colorscheme
-- =============================
vim.cmd([[colorscheme tokyonight-night]])

-- =============================
-- Keymaps
-- =============================
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>")

-- =============================
-- LSP setup (new API for Neovim 0.11+)
-- =============================
-- =============================
-- LSP setup without deprecated warnings
-- =============================
-- =============================
-- LSP setup without deprecated warnings
-- =============================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "clangd", "pyright", "lua_ls", "jdtls"},
})

-- Start servers with the new API
vim.lsp.start({
  name = "clangd",
  cmd = { "clangd" },
  root_dir = vim.fs.dirname(
    vim.fs.find({ ".git", "compile_commands.json" }, { upward = true })[1] 
    or vim.loop.cwd()
  ),
  filetypes = { "c", "cpp" },
})
vim.lsp.start({
  name = "pyright",
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
})

vim.lsp.start({
  name = "lua_ls",
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
})



-- =============================
-- Autocomplete setup
-- =============================
local cmp = require("cmp")
cmp.setup({
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = "nvim_lsp" },
  },
})

-- =============================
-- NvimTree setup
-- =============================
require("nvim-tree").setup({
  hijack_cursor = true,
  update_focused_file = { enable = true },
  view = { width = 30, side = "left" },
})

-- =============================
-- Telescope setup
-- =============================
require("telescope").setup()

-- =============================
-- Autopairs setup
-- =============================
require("nvim-autopairs").setup({})

