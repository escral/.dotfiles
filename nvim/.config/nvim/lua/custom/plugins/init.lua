-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- if modes prop not set, use  { 'n', 'i', 'v', 't' } by default

local setKey = function(key, value, opts, modes, propagate)
    modes = modes or { 'n', 'i', 'v', 't' }
    propagate = propagate or false

    local valueResult

    -- If value is a function, call it and use its return value as the value
    if type(value) == 'function' then
        local cb = value
        value = function()
            valueResult = cb()

            if valueResult ~= false then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), 'n')
            end
        end
    end

    vim.keymap.set(modes, key, value, opts)
end



return {
    -- Theme
    {
        'catppuccin/nvim',
        config = function()
            require("catppuccin").setup({
                flavour = "frappe", -- latte, frappe, macchiato, mocha
                background = {
                            -- :h background
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
                setKey('<A-b>', function()
                    api.tree.toggle()
                end, { noremap = true, silent = true }),

                view = {
                    width = 50,
                },
                renderer = {
                    root_folder_label = ":~:s?$??",
                    highlight_git = false,
                    indent_markers = {
                        enable = false,
                    }
                },

                filters = {
                    custom = {
                        '^\\.git',
                        '^\\.vscode',
                        '^\\.idea'
                    }
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
            -- setKey('<C-w>', '<Cmd>BufferClose<CR>', opts, { 'n', 'v', 't' })
            setKey('<A-w>', '<Cmd>BufferClose<CR>', opts)
            setKey('<S-A-w>', '<Cmd>BufferCloseAllButCurrent<CR>', opts)

            -- Pin/unpin tab in all modes
            setKey('<leader>bp', '<Cmd>BufferPin<CR>', { noremap = true, silent = true, desc = '[B]uffer [P]in' },
                { 'n', 'v', 't' })

            -- Pick buffer in all modes
            setKey('<leader>bn', '<Cmd>BufferPick<CR>', { noremap = true, silent = true, desc = '[B]uffer [N]avigate' },
                { 'n', 'v', 't' })

            -- Alt - {Number} to go to tab in all modes
            for i = 1, 9 do
                setKey('<A-' .. i .. '>', '<Cmd>BufferGoto ' .. i .. '<CR>', opts)
            end
        end,
        opts = {
            animation = false,
            auto_hide = true,
            maximum_padding = 1,
            minimum_padding = 1,
            no_name_title = "[New File]",
            hide = { extensions = false, inactive = false },
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
    },

    -- Some
    -- Copilot
    {
        'zbirenbaum/copilot.lua',
        config = function()
            require('copilot').setup({
                setKey('<Esc>', function()
                    if require('copilot.suggestion').is_visible() then
                        require('copilot.suggestion').dismiss()
                        -- return false
                    end
                end, { noremap = true, silent = true }, { 'i' }, true),

                setKey('<Tab>', function()
                    if require('copilot.suggestion').is_visible() then
                        require('copilot.suggestion').accept()
                        return false
                    end
                end, { noremap = true, silent = true }, { 'i' }, true),

                panel = {
                    enabled = false,
                },
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 75,
                    keymap = {
                        accept = false,
                        accept_word = false,
                        accept_line = false,
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = false,
                    },
                },
                filetypes = {
                    typescript = true,
                    javascript = true,
                    vue = true,
                    zsh = true,
                    shell = true,
                    yaml = false,
                    markdown = false,
                    help = false,
                    gitcommit = true,
                    gitrebase = false,
                    hgcommit = false,
                    svn = false,
                    cvs = false,
                    ["."] = false,
                    sh = function()
                        if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
                            -- disable for .env files
                            return false
                        end
                        return true
                    end,
                },
                copilot_node_command = 'node', -- Node.js version must be > 16.x
                server_opts_overrides = {},
            })
        end,
    },

    -- Multicursor
    {
        'mg979/vim-visual-multi',
        branch = 'master',
        config = function()
            -- Disable multicursor default mappings
            vim.g.VM_default_mappings = 0
        end
    },

    {
        'sindrets/diffview.nvim',
        requires = 'nvim-lua/plenary.nvim',
    },

    {
        'evanleck/vim-svelte',
        config = function()
            vim.g.vim_svelte_plugin_load_full_syntax = 1
        end,
    },
    
    {
        'jiangmiao/auto-pairs',
    },
}
