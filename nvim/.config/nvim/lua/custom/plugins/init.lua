-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- if modes prop not set, use  { 'n', 'i', 'v', 't' } by default

local setKey = function(key, value, opts, modes)
  modes = modes or { 'n', 'i', 'v', 't' }
  
  vim.keymap.set(modes, key, value, opts)
end

return {
  -- Theme
  {
    'catppuccin/nvim',
    config = function()
      require("catppuccin").setup({
        flavour = "frappe", -- latte, frappe, macchiato, mocha
        background = { -- :h background
            light = "latte",
            dark = "frappe",
        },
        transparent_background = false,
        show_end_of_buffer = false, -- show the '~' characters after the end of buffers
        term_colors = false,
        dim_inactive = {
            enabled = false,
            shade = "dark",
            percentage = 0.15,
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        styles = {
            comments = { "italic" },
            conditionals = { "italic" },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
            cmp = true,
            gitsigns = true,
            nvimtree = true,
            telescope = true,
            notify = false,
            mini = false,
            -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
      })
    
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    end,
  },

  -- File tree
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    priority = 1000,
    config = function()
      local api = require("nvim-tree.api")
      require("nvim-tree").setup({
          setKey('<A-1>', function()
            api.tree.toggle()
          end, { noremap = true, silent = true }),
          
          renderer = {
            root_folder_label = false,
            highlight_git = true,
            indent_markers = {
              enable = true,
            }
          },

          filters = {
            dotfiles = true,
          },
      })
    end,
  },

  -- Better tabs
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    init = function() 
      vim.g.barbar_auto_setup = false
    
      local opts = { noremap = true, silent = true }

      -- Alt + J/K to move between tabs in all modes
      setKey('<A-j>', '<Cmd>BufferPrevious<CR>', opts)
      setKey('<A-k>', '<Cmd>BufferNext<CR>', opts)

      -- Ctrl/Alt + W to close tab in all modes
      setKey('<C-w>', '<Cmd>BufferClose<CR>', opts, { 'n', 'v', 't' })
      setKey('<A-w>', '<Cmd>BufferClose<CR>', opts)

      -- Alt + P to pin/unpin tab in all modes
      setKey('<A-p>', '<Cmd>BufferPin<CR>', opts)

      -- Pick buffer in all modes
      setKey('<A-f>', '<Cmd>BufferPick<CR>', opts)

      -- Search buffer in all modes
      setKey('<A-b>', '<Cmd>BufferOrderByBufferNumber<CR>', opts)

      -- Alt - {Number} to go to tab in all modes
      for i = 1, 9 do
        setKey('<A-' .. i .. '>', '<Cmd>BufferGoto ' .. i .. '<CR>', opts)
      end
    end,
    opts = {
      auto_hide = true,
    },
  },

  -- Remember opened tabs
  {
    "olimorris/persisted.nvim",
    config = function()
      require("persisted").setup({
        silent = true, -- silent nvim message when sourcing session file
        autosave = true, -- automatically save session files when exiting Neovim
        autoload = true, -- automatically load the session for the cwd on Neovim startup
      })
    end,
  }
}
