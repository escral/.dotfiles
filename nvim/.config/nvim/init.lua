--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, and understand
  what your configuration is doing.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/

  And then you can explore or search through `:help lua-guide`


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
local setKey = function(key, value, opts, modes)
  modes = modes or { 'n', 'i', 'v', 't' }

  vim.keymap.set(modes, key, value, opts)
end

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)



-- Auto Save
vim.api.nvim_create_autocmd({ 'FocusLost' }, {
  command = 'silent! wa'
})

-- vim.opt.smartindent = true
-- vim.opt.autoindent = true
-- vim.opt.expandtab = true
-- vim.opt.shiftwidth = 4
-- vim.opt.tabstop = 4

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'sindrets/diffview.nvim',

  -- Copilot
  'github/copilot.vim',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "eslint@4.8.0",
      },
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',   opts = {} },
  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- { -- Theme inspired by Atom
  --   'navarasu/onedark.nvim',
  --   priority = 1000,
  --   config = function()
  --     -- vim.cmd.colorscheme 'onedark'
  --   end,
  -- },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',

    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        theme = 'catppuccin',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = {},
        lualine_y = { 'filetype' },
        lualine_z = { 'location' }
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    opts = {
      -- lua array of chars, which can be used as a fallback indent marker
      indent_blankline_char = '|',
      indent_blankline_char_blankline = '┆',

      show_trailing_blankline_indent = false,
      show_first_indent_level = true,
      -- show_current_context = true,
    },
  },

  {
    'stephenway/postcss.vim',
  },

  -- "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',

    config = function()
      require('Comment').setup({
        sticky = true,
        padding = true,
      })
      setKey('<C-/>', '<Plug>(comment_toggle_linewise_current)j', { noremap = false }, { 'n' })
      setKey('<C-/>', '<C-o><Plug>(comment_toggle_linewise_current)<C-o>j', { noremap = false }, { 'i' })
      setKey('<C-/>', '<Plug>(comment_toggle_linewise_visual)', { noremap = false }, { 'v' })
    end
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
      build = ":TSUpdate",
    },
  },

  {
    'kkharji/sqlite.lua',
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
  },
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below automatically adds your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  --
  --    An additional note is that if you only copied in the `init.lua`, you can just comment this line
  --    to get rid of the warning telling you that there are not plugins in `lua/custom/plugins/`.
  { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Ctrl + Z works as undo, Ctrl + Shift + Z works as redo
vim.keymap.set({ 'n', 'i', 'v', 't' }, '<C-z>', '<Cmd>u<CR>', { silent = true })
vim.keymap.set({ 'n', 'i', 'v', 't' }, '<C-S-z>', '<Cmd>redo<CR>', { silent = true })

-- Ctrl + S to save in all modes
vim.keymap.set({ 'n', 'i', 'v', 't' }, '<C-s>', '<Cmd>w<CR><Esc>')

-- Ctrl + Backspace to delete previous word in insert mode
vim.keymap.set('i', '<C-BS>', '<C-w>', { noremap = true, silent = true })
-- Ctrl + Backspace in command mode
vim.keymap.set('c', '<C-BS>', '<C-u><BS>', { noremap = true, silent = true })

-- Ctrl + Delete to delete to end of word in insert mode
vim.keymap.set('i', '<C-Del>', '<C-o>"ddw', { noremap = true, silent = true })

-- Line Copy/Cut in normal mode
vim.keymap.set('n', '<C-c>', '"+yy')
vim.keymap.set('n', '<C-x>', '"+dd')
vim.keymap.set('i', '<C-c>', '<Esc>"+yyi')
vim.keymap.set('i', '<C-x>', '<Esc>"+ddi')

-- Sync with system clipboard
vim.keymap.set({ 'v' }, '<C-c>', '"+y')
vim.keymap.set({ 'v' }, '<C-x>', '"+c')

-- Shift + Tab to unindent in visual mode
vim.keymap.set({ 'v' }, '<S-Tab>', '<gv', { silent = true })
vim.keymap.set({ 'v' }, '<Tab>', '>gv', { silent = true })

vim.keymap.set({ 'n' }, '<S-Tab>', 'v<', { silent = true })
vim.keymap.set({ 'n' }, '<Tab>', 'v>', { silent = true })

vim.keymap.set({ 'i' }, '<S-Tab>', '<C-o><gv', { silent = true })

-- Shift + Arrow to select text
vim.keymap.set({ 'n' }, '<S-Up>', 'v<Up>', { silent = true })
vim.keymap.set({ 'n' }, '<S-Down>', 'v<Down>', { silent = true })
vim.keymap.set({ 'n' }, '<S-Left>', 'v<Left>', { silent = true })
vim.keymap.set({ 'n' }, '<S-Right>', 'v<Right>', { silent = true })

vim.keymap.set({ 'v' }, '<S-Up>', '<Up>', { silent = true })
vim.keymap.set({ 'v' }, '<S-Down>', '<Down>', { silent = true })
vim.keymap.set({ 'v' }, '<S-Right>', '<Right>', { silent = true })
vim.keymap.set({ 'v' }, '<S-Left>', '<Left>', { silent = true })

vim.keymap.set({ 'i' }, '<S-Up>', '<C-o>v<Up>', { silent = true })
vim.keymap.set({ 'i' }, '<S-Down>', '<C-o>v<Down>', { silent = true })
vim.keymap.set({ 'i' }, '<S-Left>', '<C-o>v<Left>', { silent = true })
vim.keymap.set({ 'i' }, '<S-Right>', '<C-o>v<Right>', { silent = true })

-- Shift + Ctrl + Arrow to select text
vim.keymap.set({ 'n' }, '<S-C-Up>', 'v<C-Up>', { silent = true })
vim.keymap.set({ 'n' }, '<S-C-Down>', 'v<C-Down>', { silent = true })
vim.keymap.set({ 'n' }, '<S-C-Left>', 'v<C-Left>', { silent = true })
vim.keymap.set({ 'n' }, '<S-C-Right>', 'v<C-Right>', { silent = true })

vim.keymap.set({ 'v' }, '<S-C-Up>', 'k', { silent = true })
vim.keymap.set({ 'v' }, '<S-C-Down>', 'j', { silent = true })
vim.keymap.set({ 'v' }, '<S-C-Right>', 'e', { silent = true })
vim.keymap.set({ 'v' }, '<S-C-Left>', 'b', { silent = true })

vim.keymap.set({ 'i' }, '<S-C-Up>', '<C-o>v<C-Up>', { silent = true })
vim.keymap.set({ 'i' }, '<S-C-Down>', '<C-o>v<C-Down>', { silent = true })
vim.keymap.set({ 'i' }, '<S-C-Left>', '<C-o>v<C-Left>', { silent = true })
vim.keymap.set({ 'i' }, '<S-C-Right>', '<C-o>v<C-Right>', { silent = true })

-- Ctrl + Arrow to move cursor as in normal editor
vim.keymap.set({ 'n' }, '<C-Up>', '5k', { silent = true })
vim.keymap.set({ 'n' }, '<C-Down>', '5j', { silent = true })
vim.keymap.set({ 'n' }, '<C-Right>', 'e', { silent = true })
vim.keymap.set({ 'n' }, '<C-Left>', 'b', { silent = true })

-- Formatter
-- vim.keymap.set('n', '<C-S-l>', ':silent :w<CR>:silent !npx eslint --fix %<CR>', {noremap = true})
vim.keymap.set({ 'i' }, '<C-S-l>', '<C-o>:Format<CR>', { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<C-S-l>', ':Format<CR>', { noremap = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local telescopeActions = require('telescope.actions')
local telescopeUtils = require('telescope.utils')

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<Tab>'] = telescopeActions.select_default,
        ['<Return>'] = telescopeActions.select_default,
        ["<C-j>"] = {
          telescopeActions.move_selection_next, type = "action",
          opts = { nowait = true, silent = true }
        },
        ["<A-j>"] = {
          telescopeActions.move_selection_next, type = "action",
          opts = { nowait = true, silent = true }
        },
        -- Inverted because the popup is mirrored
        ["<C-k>"] = {
          telescopeActions.move_selection_previous, type = "action",
          opts = { nowait = true, silent = true }
        },
        ["<A-k>"] = {
          telescopeActions.move_selection_previous, type = "action",
          opts = { nowait = true, silent = true }
        },
        ["<Esc>"] = require('telescope.actions').close,
        ["<A-Down>"] = require('telescope.actions').cycle_history_next,
        ["<A-Up>"] = require('telescope.actions').cycle_history_prev,

        ['<C-BS>'] = function(prompt_bufnr)
          vim.cmd ":normal! db"
        end,

        ['<C-v>'] = false,
      },
    },

    history = {
      path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
      limit = 100,
    },

    prompt_prefix = '',
    selection_caret = '❯ ',
    entry_prefix = '  ',
    results_title = false,

    path_display = function(opts, path)
      local tail = telescopeUtils.path_tail(path)

      -- Split path by slash
      -- Get first and last 3 elements
      -- Join them with slash, inserting ... in the middle if needed
      local parts = vim.split(path, "/")

      local truncatedFromBeginning = path

      if (#parts > 1) then
        vim.list_slice(parts, 0, #parts - 1)
      end

      if #parts > 7 then
        local first = table.concat(vim.list_slice(parts, 0, 1), "/")
        local last = table.concat(vim.list_slice(parts, #parts - 5, #parts - 1), "/")

        truncatedFromBeginning = string.format("%s/../%s", first, last)
      end

      -- local ext = vim.fn.fnamemodify(path, ":e")

      return string.format(" %-26s  %s", tail, truncatedFromBeginning)
    end,

    file_ignore_patterns = { "node_modules/", ".git/", ".vscode", ".cache/", "dist/", "^vendor/" },

    theme = {
      prompt_title = { fg = "#ff0000", bg = "#00ff00" },
    },

    sorting_strategy = "ascending",
    layout_config = {
      horizontal = {
        prompt_position = "top",
      },
    },

    hidden = true,

    extensions = {
      persisted = {
        layout_config = { width = 0.55, height = 0.55 }
      },
      fzf = {
        fuzzy = true,                   -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      }
    }
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'persisted')
pcall(require('telescope').load_extension, 'smart_history')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local findFiles = function()
  require('telescope.builtin').find_files({ hidden = true })
end

-- Bind ctrl-p to telescope
vim.keymap.set({ 'n', 'v', 't' }, '<leader>p', findFiles, { desc = '[P]ick file' })
vim.keymap.set({ 'n', 'v', 't', 'i' }, '<A-p>', findFiles, { desc = '[P]ick file' })
vim.keymap.set({ 'n', 'v', 't', 'i' }, '<C-p>', findFiles, { desc = '[P]ick file' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').oldfiles, { desc = '[S]earch [R]ecent Files' })
vim.keymap.set('n', '<C-r>', require('telescope.builtin').lsp_document_symbols, { desc = '[S]earch [S]ymbols' })
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').git_branches, { desc = '[S]earch [B]ranches' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'lua', 'tsx', 'typescript', 'javascript', 'vimdoc', 'vim', 'php', 'vue', 'scss', 'html', 'tsx',
    'twig' },

  context_commentstring = {
    enable = true,
  },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<C-b>', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  local function eslint_attached(bufnr)
    bufnr = bufnr or 0
    for _, c in ipairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
      if c.name == "eslint" then return true end
    end
    return false
  end

  local function eslint_fix_all(bufnr)
    bufnr = bufnr or 0

    -- 1) Try :EslintFixAll if your plugin exposes it
    local ok = pcall(vim.cmd, "EslintFixAll")
    if ok then return true end

    -- 2) Fallback: request ESLint code action programmatically
    if not eslint_attached(bufnr) then return false end
    vim.lsp.buf.code_action({
      apply = true,
      context = { only = { "source.fixAll.eslint" }, diagnostics = {} },
    })
    return true
  end

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    if eslint_attached(0) and eslint_fix_all(0) then
      return
    end
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  tsserver = {},
  html = {},
  cssls = {
    css = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    }
  },
  eslint = {
    format = { enable = true },
    lint = { enable = true },
    workingDirectory = { mode = "auto" },
    experimental = { useFlatConfig = true },
  },
  jsonls = {},
  volar = {},
  tailwindcss = {},

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

require("luasnip.loaders.from_vscode").lazy_load {
  -- exclude = { "javascript" },
}

require 'luasnip'.filetype_extend("typescript", { "javascript" })
require 'luasnip'.filetype_extend("svelte", { "typescript" })

luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if (require('copilot.suggestion').is_visible()) then
        fallback()
        -- do nothing, handled by copilot
      elseif cmp.visible() then
        cmp.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        })
      else
        fallback()
      end
    end, { 'i', 's' }),
    -- ['<Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   elseif luasnip.expand_or_jumpable() then
    --     luasnip.expand_or_jump()
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    -- ['<S-Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   elseif luasnip.jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp', max_item_count = 15 },
    { name = 'luasnip',  max_item_count = 15 },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
