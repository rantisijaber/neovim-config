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
-- Filetype detection for SystemVerilog + C3
-- =============================
-- Neovim's built-in filetype detection already handles .v/.sv/.svh as
-- "verilog"/"systemverilog", but this makes sure it's explicit.
-- C3 uses .c3 for source files and .c3i for interface/header files;
-- neither is known to Neovim by default, so both are added here.
vim.filetype.add({
  extension = {
    sv = "systemverilog",
    svh = "systemverilog",
    v = "verilog",
    c3 = "c3",
    c3i = "c3",
  },
})

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

  -- SystemVerilog LSP frontend (slang-server enhanced features)
  { "hudson-trading/slang-server.nvim" },

  -- Java LSP (jdtls) -- needs its own plugin since it requires a
  -- per-project workspace dir and exposes extra code-action commands
  -- (organize imports, extract variable/method, etc.) beyond plain LSP.
  { "mfussenegger/nvim-jdtls", ft = "java" },

  -- C3 query source (not a runtime plugin -- this has no plugin/ or lua/
  -- to load, it's cloned purely so we have a persistent, auto-updating
  -- local copy of the grammar repo's queries/ folder). On nvim-treesitter's
  -- "master" branch, parser_config.install_info has no way to fetch a
  -- custom parser's query files (that's a main-branch-only feature), so we
  -- sync them ourselves via this build step -- which reruns automatically
  -- on every `:Lazy sync`/update, unlike a one-off manual curl.
  {
    "c3lang/tree-sitter-c3",
    lazy = true,
    build = function()
      local src = vim.fn.stdpath("data") .. "/lazy/tree-sitter-c3/queries"
      local dest = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/queries/c3"
      if vim.fn.isdirectory(src) == 1 then
        vim.fn.mkdir(dest, "p")
        vim.fn.system({ "sh", "-c", string.format("cp -f '%s'/*.scm '%s'/", src, dest) })
      end
    end,
  },

  -- Treesitter
  -- Pinned to "master" (the legacy branch) rather than "main": nvim-treesitter
  -- shipped a full, intentionally incompatible rewrite on main that removes
  -- configs.setup({ ensure_installed, highlight, indent }) and
  -- parsers.get_parser_configs() entirely, replacing them with a lower-level
  -- manual API. Our config (and the rainbow/autopairs submodules) relies on
  -- the old module system, so master is the correct branch here.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- c3 is NOT in nvim-treesitter's built-in parser registry, so just
      -- listing "c3" in ensure_installed does nothing (or errors with
      -- "no parser for lang c3"). It has to be registered by hand, pointing
      -- straight at the official grammar repo, before ensure_installed can
      -- find it.
      --
      -- Note: there's no "queries" field here, unlike some examples you'll
      -- find online -- that key only exists on nvim-treesitter's newer
      -- "main" branch installer. On "master" (which we're pinned to, see
      -- above) it's silently ignored, so highlight queries are instead kept
      -- in sync via the c3lang/tree-sitter-c3 plugin entry above, whose
      -- build step copies them into nvim-treesitter's queries/c3/ folder.
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.c3 = {
        install_info = {
          url = "https://github.com/c3lang/tree-sitter-c3",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "main",
        },
        filetype = "c3",
      }

      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if ok then
        ts.setup({
          ensure_installed = {
            "c", "java", "cpp", "lua", "python", "javascript", "html", "css",
            "verilog", -- covers Verilog/SystemVerilog syntax highlighting
            "c3",      -- official C3 grammar, registered above
          },
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
require("mason").setup()
require("mason-lspconfig").setup({
  -- NOTE: c3-lsp is intentionally NOT listed here. mason-lspconfig validates
  -- ensure_installed against nvim-lspconfig's built-in server registry, and
  -- c3-lsp isn't in it yet, which throws:
  --   "Server 'c3lsp' is not a valid entry in ensure_installed."
  -- It's still a real Mason package though, so it's installed directly
  -- below and wired up by hand via vim.lsp.config/vim.lsp.enable, exactly
  -- like slang_server.
  ensure_installed = { "clangd", "pyright", "lua_ls", "jdtls", "slang_server" },
})

-- Install c3-lsp's binary via Mason directly, since mason-lspconfig won't
-- manage it (see note above). Safe to call repeatedly -- it's a no-op once
-- installed. Remove this block if you'd rather install manually with
-- :MasonInstall c3-lsp or keep the binary on your PATH yourself.
local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
if mason_registry_ok then
  mason_registry.refresh(function()
    local ok, pkg = pcall(mason_registry.get_package, "c3-lsp")
    if ok and not pkg:is_installed() then
      pkg:install()
    end
  end)
end

-- Capabilities that tell servers we support nvim-cmp's completion features
-- (snippets, etc.) -- without this, completion can be more limited.
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Start servers with the new API
vim.lsp.start({
  name = "clangd",
  cmd = { "clangd" },
  root_dir = vim.fs.dirname(
    vim.fs.find({ ".git", "compile_commands.json" }, { upward = true })[1]
      or vim.loop.cwd()
  ),
  filetypes = { "c", "cpp" },
  capabilities = capabilities,
})

vim.lsp.start({
  name = "pyright",
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  capabilities = capabilities,
})

vim.lsp.start({
  name = "lua_ls",
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  capabilities = capabilities,
})

-- =============================
-- SystemVerilog / Verilog LSP (slang-server, by Hudson River Trading)
-- =============================
-- Install the binary via :MasonInstall slang-server (handled above by
-- mason-lspconfig ensure_installed), or place `slang-server` on your PATH
-- manually if you'd rather not use Mason for it.
--
-- We define the config explicitly with vim.lsp.config() rather than relying
-- on nvim-lspconfig shipping a built-in lsp/slang_server.lua -- some
-- versions of that plugin don't have it yet, which causes the
-- "'slang_server' config not found" warning in :checkhealth vim.lsp.
vim.lsp.config("slang_server", {
  cmd = { "slang-server" },
  filetypes = { "verilog", "systemverilog" },
  root_markers = { ".git", "*.xdc" },
  capabilities = capabilities,
})
vim.lsp.enable("slang_server")

-- =============================
-- C3 LSP (c3-lsp, by pherrymason)
-- =============================
-- The binary is installed directly via mason-registry above (Mason package
-- name "c3-lsp"; not managed by mason-lspconfig -- see note above), or you
-- can place `c3lsp` on your PATH manually instead.
--
-- nvim-lspconfig has no built-in lsp/c3lsp.lua yet, so we define the config
-- explicitly with vim.lsp.config() to avoid a "'c3lsp' config not found"
-- warning -- same approach as slang_server.
-- root_markers uses project.json since that's the standard C3 project file
-- (see c3lang/tree-sitter-c3's editor integration notes).
vim.lsp.config("c3lsp", {
  cmd = { "c3lsp" },
  filetypes = { "c3" },
  root_markers = { "project.json", ".git" },
  capabilities = capabilities,
})
vim.lsp.enable("c3lsp")

-- =============================
-- Java LSP (jdtls)
-- =============================
-- jdtls is different from the servers above: it needs a unique workspace
-- directory per project and should be (re)started whenever a Java file is
-- opened, rather than once at startup with vim.lsp.start(). We use
-- nvim-jdtls's start_or_attach for this, wired up via a FileType autocmd.
--
-- Binary is installed via Mason (see ensure_installed above: "jdtls").
-- Optional extras for debugging/testing support:
--   :MasonInstall java-debug-adapter java-test
local jdtls_group = vim.api.nvim_create_augroup("JdtlsSetup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = jdtls_group,
  pattern = "java",
  callback = function()
    local ok, jdtls = pcall(require, "jdtls")
    if not ok then
      return
    end

    -- Find project root; falls back gracefully if none of these markers exist
    local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
    if not root_dir then
      return
    end

    -- Unique workspace dir per project so jdtls doesn't mix state across projects
    local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

    local config = {
      cmd = { "jdtls", "-data", workspace_dir },
      root_dir = root_dir,
      capabilities = capabilities,

      settings = {
        java = {
          signatureHelp = { enabled = true },
          completion = { favoriteStaticMembers = {} },
        },
      },

      -- Enables extra jdtls features (extract var/method, organize imports, etc.)
      init_options = {
        bundles = {},
      },
    }

    jdtls.start_or_attach(config)

    -- Java-specific keymaps (buffer-local, only active in .java files)
    vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, { buffer = 0, desc = "Java: Organize Imports" })
    vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, { buffer = 0, desc = "Java: Extract Variable" })
    vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, { buffer = 0, desc = "Java: Extract Constant" })
    vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end, { buffer = 0, desc = "Java: Extract Method" })
  end,
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
