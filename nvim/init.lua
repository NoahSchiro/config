-- Map leader -> space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Line numbers relative
vim.wo.number = true
vim.wo.relativenumber = true

-- Allow mouse
vim.o.mouse = 'a'

-- Sync clipboard
vim.o.clipboard = 'unnamedplus'

-- Line break long lines
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive search unless we put a capital in the search
vim.o.ignorecase = true
vim.o.smartcase = true

-- 24 bit colors
vim.o.termguicolors = true

vim.opt.tabstop    = 4
vim.opt.shiftwidth = 4

-- Lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- Theme
  {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {},
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Adds git releated signs to the gutter, as well as utilities for managing changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Set shiftwidth based on file type automatically
  { "tpope/vim-sleuth", event = "BufReadPre" },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = "cd app && npm install",
    keys = {
      { "<leader>m", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
    config = function()
      vim.g.mkdp_auto_start = 0       -- don't open automatically on entering a md file
      vim.g.mkdp_auto_close = 1       -- close preview when leaving the md buffer
      vim.g.mkdp_refresh_slow = 0     -- refresh in real time (not on save only)
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_browser = ""         -- use system default browser, or set e.g. "firefox"
      vim.g.mkdp_theme = "dark"       -- "dark" or "light"
      vim.g.mkdp_preview_options = {
        sync_scroll_type = "top",
        hide_yaml_meta = 1,
        disable_filename = 0,
      }
    end,
  },

  {
    'chomosuke/typst-preview.nvim',
    lazy = false,
    version = '1.*',
    keys = {
      { "<leader>tp", "<cmd>TypstPreviewToggle<cr>", desc = "Typst Preview" },
    },
    opts = {},
  },
  
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    enabled = true,
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      -- If you need help to see what telescope can do:
      -- :Telescope
      require('telescope').setup {
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      -- Keybindings
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      -- Files (from where you launched nvim)
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })

      -- This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
      -- it is better explained there). This allows easily switching between pickers if you prefer using something else!
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf

          -- Find references for the word under your cursor.
          vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

          -- Jump to the implementation of the word under your cursor.
          -- Useful when your language has ways of declaring types without an actual implementation.
          vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

          -- Jump to the definition of the word under your cursor.
          -- This is where a variable was first declared, or where a function is defined, etc.
          -- To jump back, press <C-t>.
          vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

          -- Fuzzy find all the symbols in your current document.
          -- Symbols are things like variables, functions, types, etc.
          vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

          -- Fuzzy find all the symbols in your current workspace.
          -- Similar to document symbols, except searches over your entire project.
          vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

          -- Jump to the type of the word under your cursor.
          -- Useful when you're not sure what type a variable is and you want to see
          -- the definition of its *type*, not where it was *defined*.
          vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
        end,
      })

      -- Override default behavior and theme when searching
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'mason-org/mason.nvim',
        ---@module 'mason.settings'
        ---@type MasonSettings
        ---@diagnostic disable-next-line: missing-fields
        opts = {},
      },
      -- Maps LSP server names between nvim-lspconfig and Mason package names.
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          vim.keymap.set('n', 'grn', vim.lsp.buf.rename, { buffer = event.buf, desc = 'LSP: ' .. '[R]e[n]ame' })
        end,
      })

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --  See `:help lsp-config` for information about keys and how to configure
      ---@type table<string, vim.lsp.Config>
      local servers = {
        clangd = {}, -- C/C++
        gopls = {}, -- Go
        pyright = {}, -- Python
        rust_analyzer = {}, -- Rust
        ts_ls = {}, -- Typescript
        stylua = {}, -- Used to format Lua code
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  },

  -- Highlight, edit, and navigate code
  { 
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
    config = function()
      -- ensure basic parser are installed
      local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
      require('nvim-treesitter').install(parsers)

      ---@param buf integer
      ---@param language string
      local function treesitter_try_attach(buf, language)
        -- check if parser exists and load it
        if not vim.treesitter.language.add(language) then return end
        -- enables syntax highlighting and other treesitter features
        vim.treesitter.start(buf, language)

        -- enables treesitter based folds
        -- for more info on folds see `:help folds`
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- vim.wo.foldmethod = 'expr'

        -- enables treesitter based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      local available_parsers = require('nvim-treesitter').get_available()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then return end

          local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

          if vim.tbl_contains(installed_parsers, language) then
            -- enable the parser if it is installed
            treesitter_try_attach(buf, language)
          elseif vim.tbl_contains(available_parsers, language) then
            -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
            require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
          else
            -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
            treesitter_try_attach(buf, language)
          end
        end,
      })
    end,
  },

}, {})

-- vim: ts=2 sts=2 sw=2 et
