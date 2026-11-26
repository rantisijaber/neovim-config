vim.g.mapleader = " "

vim.g.zig_fmt_autosave = 0
vim.g.zig_fmt_parse_errors = 0

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

vim.filetype.add({
  extension = {
    sv = "systemverilog",
    svh = "systemverilog",
    v = "verilog",
    c3 = "c3",
    c3i = "c3",
    zig = "zig",
    zon = "zig",
  },
})

require("lazy").setup({

  {
    "folke/tokyonight.nvim",
  },

  {
    "lervag/vimtex",
    ft = "tex",
    config = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_syntax_enabled = 1
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
  },

  {
    "saadparwaiz1/cmp_luasnip",
  },

  {
    "neovim/nvim-lspconfig",
  },

  {
    "williamboman/mason.nvim",
  },

  {
    "williamboman/mason-lspconfig.nvim",
  },

  {
    "hrsh7th/nvim-cmp",
  },

  {
    "hrsh7th/cmp-nvim-lsp",
  },

  {
    "nvim-tree/nvim-tree.lua",
  },

  {
    "nvim-tree/nvim-web-devicons",
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  {
    "windwp/nvim-autopairs",
  },

  {
    "hudson-trading/slang-server.nvim",
  },

  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },

  {
    "c3lang/tree-sitter-c3",
    lazy = true,

    build = function()
      local src =
        vim.fn.stdpath("data") .. "/lazy/tree-sitter-c3/queries"

      local dest =
        vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/queries/c3"

      if vim.fn.isdirectory(src) == 1 then
        vim.fn.mkdir(dest, "p")

        vim.fn.system({
          "sh",
          "-c",
          string.format(
            "cp -f '%s'/*.scm '%s'/",
            src,
            dest
          ),
        })
      end
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",

    config = function()

      local parser_config =
        require("nvim-treesitter.parsers").get_parser_configs()

      parser_config.c3 = {
        install_info = {
          url = "https://github.com/c3lang/tree-sitter-c3",
          files = {
            "src/parser.c",
            "src/scanner.c",
          },
          branch = "main",
        },

        filetype = "c3",
      }

      local ok, ts =
        pcall(require, "nvim-treesitter.configs")

      if ok then
        ts.setup({
          ensure_installed = {
            "c",
            "cpp",
            "java",
            "lua",
            "python",
            "javascript",
            "html",
            "css",
            "verilog",
            "c3",
            "zig",
          },

          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },

          indent = {
            enable = true,
          },
        })
      end
    end,
  },
})

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

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.cmd([[colorscheme tokyonight-night]])

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = "if_many",
  },

  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,

  float = {
    border = "rounded",
    source = true,
    header = "",
  },
})

vim.keymap.set(
  "n",
  "<leader>e",
  ":NvimTreeToggle<CR>",
  { desc = "File tree" }
)

vim.keymap.set(
  "n",
  "<leader>f",
  ":Telescope find_files<CR>",
  { desc = "Find files" }
)

vim.keymap.set(
  "n",
  "<leader>g",
  ":Telescope live_grep<CR>",
  { desc = "Grep project" }
)

vim.keymap.set(
  "n",
  "<leader>b",
  ":Telescope buffers<CR>",
  { desc = "Buffers" }
)

vim.keymap.set(
  "n",
  "<leader>h",
  ":Telescope help_tags<CR>",
  { desc = "Help tags" }
)

vim.keymap.set(
  "n",
  "<leader>D",
  ":Telescope diagnostics<CR>",
  { desc = "All diagnostics" }
)

vim.keymap.set(
  "n",
  "<leader>r",
  ":Telescope lsp_references<CR>",
  { desc = "References" }
)

vim.keymap.set(
  "n",
  "<leader>s",
  ":Telescope lsp_document_symbols<CR>",
  { desc = "Symbols" }
)

vim.keymap.set(
  "n",
  "<leader>d",
  vim.diagnostic.open_float,
  { desc = "Line diagnostics" }
)

vim.keymap.set(
  "n",
  "[d",
  function()
    vim.diagnostic.jump({
      count = -1,
      float = true,
    })
  end,
  { desc = "Previous diagnostic" }
)

vim.keymap.set(
  "n",
  "]d",
  function()
    vim.diagnostic.jump({
      count = 1,
      float = true,
    })
  end,
  { desc = "Next diagnostic" }
)

vim.api.nvim_create_autocmd(
  "LspAttach",
  {
    callback = function(args)

      local opts = {
        buffer = args.buf,
      }

      vim.keymap.set(
        "n",
        "gd",
        vim.lsp.buf.definition,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "Go to definition" }
        )
      )

      vim.keymap.set(
        "n",
        "<leader>rn",
        vim.lsp.buf.rename,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "Rename" }
        )
      )

      vim.keymap.set(
        "n",
        "<leader>ca",
        vim.lsp.buf.code_action,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "Code action" }
        )
      )
    end,
  }
)

require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "clangd",
    "pyright",
    "lua_ls",
    "jdtls",
    "slang_server",
    "texlab",
    "zls",
  },

  automatic_enable = false,
})

local mason_registry_ok, mason_registry =
  pcall(require, "mason-registry")

if mason_registry_ok then

  mason_registry.refresh(function()

    local ok, pkg =
      pcall(
        mason_registry.get_package,
        "c3-lsp"
      )

    if ok and not pkg:is_installed() then
      pkg:install()
    end
  end)
end

local capabilities =
  require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
  },

  filetypes = {
    "c",
    "cpp",
  },

  root_markers = {
    ".git",
    "compile_commands.json",
  },

  capabilities = capabilities,
})

vim.lsp.config("pyright", {
  cmd = {
    "pyright-langserver",
    "--stdio",
  },

  filetypes = {
    "python",
  },

  root_markers = {
    "pyproject.toml",
    "setup.py",
    "requirements.txt",
    ".git",
  },

  capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
  cmd = {
    "lua-language-server",
  },

  filetypes = {
    "lua",
  },

  root_markers = {
    ".luarc.json",
    ".git",
  },

  capabilities = capabilities,

  settings = {
    Lua = {
      diagnostics = {
        globals = {
          "vim",
        },
      },
    },
  },
})

vim.lsp.config("texlab", {
  cmd = {
    "texlab",
  },

  filetypes = {
    "tex",
    "plaintex",
    "bib",
  },

  root_markers = {
    ".git",
    "main.tex",
  },

  capabilities = capabilities,

  settings = {
    texlab = {
      build = {
        executable = "latexmk",

        args = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
          "%f",
        },

        onSave = true,
        forwardSearchAfter = false,
      },

      chktex = {
        onOpenAndSave = true,
        onEdit = false,
      },
    },
  },
})

vim.lsp.config("slang_server", {
  cmd = {
    "slang-server",
  },

  filetypes = {
    "verilog",
    "systemverilog",
  },

  root_markers = {
    ".git",
    "*.xdc",
  },

  capabilities = capabilities,
})

vim.lsp.config("c3lsp", {
  cmd = {
    "c3lsp",
  },

  filetypes = {
    "c3",
  },

  root_markers = {
    "project.json",
    ".git",
  },

  capabilities = capabilities,
})

vim.lsp.config("zls", {
  cmd = {
    "zls",
  },

  filetypes = {
    "zig",
    "zir",
  },

  root_markers = {
    "build.zig",
    "build.zig.zon",
    "zls.json",
    ".git",
  },

  capabilities = capabilities,

  settings = {
    zls = {
      enable_build_on_save = true,
      build_on_save_step = "check",

      semantic_tokens = "partial",
      warn_style = true,
      highlight_global_var_declarations = true,
      enable_argument_placeholders = true,
    },
  },
})

vim.lsp.enable({
  "clangd",
  "pyright",
  "lua_ls",
  "texlab",
  "slang_server",
  "c3lsp",
  "zls",
})

local zig_group =
  vim.api.nvim_create_augroup(
    "ZigSetup",
    { clear = true }
  )

vim.api.nvim_create_autocmd(
  "BufWritePre",
  {
    group = zig_group,
    pattern = {
      "*.zig",
      "*.zon",
    },

    callback = function(args)
      vim.lsp.buf.format({
        bufnr = args.buf,
        async = false,
        timeout_ms = 2000,
      })
    end,
  }
)

vim.api.nvim_create_autocmd(
  "FileType",
  {
    group = zig_group,
    pattern = "zig",

    callback = function()
      vim.keymap.set(
        "n",
        "<leader>zb",
        ":split | terminal zig build<CR>",
        {
          buffer = 0,
          desc = "Zig: Build",
        }
      )

      vim.keymap.set(
        "n",
        "<leader>zr",
        ":split | terminal zig build run<CR>",
        {
          buffer = 0,
          desc = "Zig: Build & Run",
        }
      )

      vim.keymap.set(
        "n",
        "<leader>zt",
        ":split | terminal zig build test<CR>",
        {
          buffer = 0,
          desc = "Zig: Test",
        }
      )

      vim.keymap.set(
        "n",
        "<leader>zf",
        function()
          vim.cmd("split | terminal zig run " .. vim.fn.shellescape(vim.fn.expand("%")))
        end,
        {
          buffer = 0,
          desc = "Zig: Run current file",
        }
      )
    end,
  }
)

local function run_in_term(cmd)
  vim.cmd("write")
  vim.cmd("split | terminal " .. cmd)
end

local c_group =
  vim.api.nvim_create_augroup(
    "CBuild",
    { clear = true }
  )

vim.api.nvim_create_autocmd(
  "FileType",
  {
    group = c_group,
    pattern = "c",

    callback = function()

      local function paths()
        local src = vim.fn.shellescape(vim.fn.expand("%:p"))
        local out = vim.fn.shellescape(vim.fn.expand("%:p:r"))
        return src, out
      end

      vim.keymap.set(
        "n",
        "<leader>cc",
        function()
          local src, out = paths()
          run_in_term("cc -Wall -Wextra -g -std=c17 " .. src .. " -o " .. out)
        end,
        {
          buffer = 0,
          desc = "C: Compile file",
        }
      )

      vim.keymap.set(
        "n",
        "<leader>cr",
        function()
          local src, out = paths()
          run_in_term(
            "cc -Wall -Wextra -g -std=c17 " .. src .. " -o " .. out
            .. " && " .. out
          )
        end,
        {
          buffer = 0,
          desc = "C: Compile & Run file",
        }
      )

      vim.keymap.set(
        "n",
        "<leader>cm",
        function()
          run_in_term("make")
        end,
        {
          buffer = 0,
          desc = "C: make",
        }
      )
    end,
  }
)

local c3_group =
  vim.api.nvim_create_augroup(
    "C3Build",
    { clear = true }
  )

vim.api.nvim_create_autocmd(
  "FileType",
  {
    group = c3_group,
    pattern = "c3",

    callback = function()

      local function src()
        return vim.fn.shellescape(vim.fn.expand("%:p"))
      end

      vim.keymap.set(
        "n",
        "<leader>3c",
        function()
          run_in_term("c3c compile " .. src())
        end,
        {
          buffer = 0,
          desc = "C3: Compile file",
        }
      )

      vim.keymap.set(
        "n",
        "<leader>3f",
        function()
          run_in_term("c3c compile-run " .. src())
        end,
        {
          buffer = 0,
          desc = "C3: Compile & Run file",
        }
      )

      local function in_project(cmd)
        local root = vim.fs.root(0, "project.json")
        if not root then
          vim.notify(
            "C3: no project.json found above this file",
            vim.log.levels.ERROR
          )
          return
        end
        run_in_term("cd " .. vim.fn.shellescape(root) .. " && " .. cmd)
      end

      vim.keymap.set(
        "n",
        "<leader>3a",
        function()
          local dir = vim.fn.shellescape(vim.fn.expand("%:p:h"))
          run_in_term(
            "c3c compile-run $(find " .. dir .. " -name '*.c3')"
          )
        end,
        {
          buffer = 0,
          desc = "C3: Compile & Run all files in folder",
        }
      )

      vim.keymap.set(
        "n",
        "<leader>3b",
        function()
          in_project("c3c build")
        end,
        {
          buffer = 0,
          desc = "C3: Build project",
        }
      )

      vim.keymap.set(
        "n",
        "<leader>3r",
        function()
          in_project("c3c run")
        end,
        {
          buffer = 0,
          desc = "C3: Build & Run project",
        }
      )
    end,
  }
)

local jdtls_group =
  vim.api.nvim_create_augroup(
    "JdtlsSetup",
    { clear = true }
  )

vim.api.nvim_create_autocmd(
  "FileType",
  {
    group = jdtls_group,
    pattern = "java",

    callback = function()

      local ok, jdtls =
        pcall(require, "jdtls")

      if not ok then
        return
      end

      local root_dir =
        require("jdtls.setup").find_root({
          ".git",
          "mvnw",
          "gradlew",
          "pom.xml",
          "build.gradle",
        })

      if not root_dir then
        return
      end

      local project_name =
        vim.fn.fnamemodify(
          root_dir,
          ":p:h:t"
        )

      local workspace_dir =
        vim.fn.stdpath("data")
        .. "/jdtls-workspace/"
        .. project_name

      local config = {
        cmd = {
          "jdtls",
          "-data",
          workspace_dir,
        },

        root_dir = root_dir,

        capabilities = capabilities,

        settings = {
          java = {
            signatureHelp = {
              enabled = true,
            },

            completion = {
              favoriteStaticMembers = {},
            },
          },
        },

        init_options = {
          bundles = {},
        },
      }

      jdtls.start_or_attach(config)

      vim.keymap.set(
        "n",
        "<leader>jo",
        jdtls.organize_imports,
        {
          buffer = 0,
          desc = "Java: Organize Imports",
        }
      )

      vim.keymap.set(
        "n",
        "<leader>jv",
        jdtls.extract_variable,
        {
          buffer = 0,
          desc = "Java: Extract Variable",
        }
      )

      vim.keymap.set(
        "n",
        "<leader>jc",
        jdtls.extract_constant,
        {
          buffer = 0,
          desc = "Java: Extract Constant",
        }
      )

      vim.keymap.set(
        "v",
        "<leader>jm",
        function()
          jdtls.extract_method(true)
        end,
        {
          buffer = 0,
          desc = "Java: Extract Method",
        }
      )
    end,
  }
)

local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = {
    ["<C-d>"] =
      cmp.mapping.scroll_docs(-4),

    ["<C-f>"] =
      cmp.mapping.scroll_docs(4),

    ["<C-Space>"] =
      cmp.mapping.complete(),

    ["<CR>"] =
      cmp.mapping.confirm({
        select = true,
      }),

    ["<Tab>"] = cmp.mapping(function(fallback)

      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end

    end, {
      "i",
      "s",
    }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)

      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      elseif cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end

    end, {
      "i",
      "s",
    }),
  },

  sources = {
    {
      name = "nvim_lsp",
    },

    {
      name = "luasnip",
    },
  },
})

require("nvim-tree").setup({
  hijack_cursor = true,

  update_focused_file = {
    enable = true,
  },

  view = {
    width = 30,
    side = "left",
  },
})

vim.keymap.set("x", "<leader>cm", function()
  local s, e = vim.fn.line("v"), vim.fn.line(".")
  if s > e then s, e = e, s end

  local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)

  for i, l in ipairs(lines) do
    lines[i] = (l:gsub("%s*\\%s*$", ""):gsub("%s+$", ""))
  end

  local width = 0
  for i = 1, #lines - 1 do
    width = math.max(width, vim.fn.strdisplaywidth(lines[i]))
  end

  for i = 1, #lines - 1 do
    local pad = width - vim.fn.strdisplaywidth(lines[i]) + 1
    lines[i] = lines[i] .. string.rep(" ", pad) .. "\\"
  end

  vim.api.nvim_buf_set_lines(0, s - 1, e, false, lines)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "C: add macro backslashes to selection" })

vim.lsp.config("ocamllsp", {
  cmd = { "ocamllsp" },
  filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
  root_markers = { "dune-project", "dune-workspace", "*.opam", ".git" },
})
vim.lsp.enable("ocamllsp")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ocaml", "ocaml.interface", "dune" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.ml", "*.mli" },
  callback = function() vim.lsp.buf.format({ async = false }) end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local o = { buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, o)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)
  end,
})

require("telescope").setup()

require("nvim-autopairs").setup({})
