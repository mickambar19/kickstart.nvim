vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Use less space for tabs
vim.opt.tabstop = 4
-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--
vim.keymap.set('n', '<leader>tl', function()
  local number = vim.o.number
  local relativenumber = vim.o.relativenumber

  -- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
  -- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
  -- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
  -- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
  -- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

  if number and relativenumber then
    -- Show only numbers
    vim.opt.number = true
    vim.opt.relativenumber = false
  elseif not number and relativenumber then
    -- Show relative numbers and line number
    vim.opt.number = true
    vim.opt.relativenumber = true
  elseif number and not relativenumber then
    -- Show relative numbers
    vim.opt.number = false
    vim.opt.relativenumber = true
  end
end, { desc = '[T]oggle [L]ine numbers' })

--- Copilot related ---
vim.keymap.set('n', '<leader>ta', function()
  vim.g.copilot_enabled = not vim.g.copilot_enabled
  local status = vim.g.copilot_enabled and 'enabled' or 'disabled'
  vim.notify('Copilot ' .. status, vim.log.levels.INFO)
end, { desc = '[T]oggle [A]I Copilot' })

-- Copilot related end

vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set('n', '<leader>wh', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<leader>wl', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<leader>wj', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<leader>wk', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
-- Split window navigation improvements
vim.keymap.set('n', '<leader>wcl', ':vsplit<CR>', { desc = '[W]indow [C]reate split [l] right' })
vim.keymap.set('n', '<leader>wcj', ':split<CR>', { desc = '[W]indow [C]reate split [j] down' })

vim.keymap.set('n', '<leader>x', '<cmd>close<CR>', { desc = 'Close window' })
vim.keymap.set('n', '<leader>X', '<cmd>qa<CR>', { desc = 'Close all windows' })
vim.keymap.set('n', '<C-w>x', '<C-w>c', { desc = 'Close window keep buffer' })

vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quick [Q]uit' })

vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Move half-page up and center' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Move half-page down and center' })

vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result and center' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result and center' })

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })

-- Keep cursor position when joining lines
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines and keep cursor position' })

vim.keymap.set('n', '<leader>fw', ':w<CR>', { desc = '[F]file [W]rite (save)' })
vim.keymap.set('n', '<leader>fW', function()
  local old_eventignore = vim.opt.eventignore
  vim.opt.eventignore:extend { 'BufWritePre' }
  -- Save the file
  vim.cmd 'write'
  -- Restore previous eventignore setting
  vim.opt.eventignore = old_eventignore
end, { desc = '[F]ile [W]rite without formatting' })
-- Quick buffer navigation
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = '[B]uffer [N]ext' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = '[B]uffer [D]elete' })

-- Quick tab navigation
vim.keymap.set('n', '<leader>tc', ':tabnew<CR>', { desc = '[T]ab [C]reate' })
vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', { desc = '[T]ab [x] close' })
vim.keymap.set('n', '<leader>to', ':tabonly<CR>', { desc = '[T]ab [O]nly - close others' })
vim.keymap.set('n', '<leader>tn', function()
  if vim.fn.tabpagenr '$' == vim.fn.tabpagenr() then
    vim.cmd 'tabfirst'
  else
    vim.cmd 'tabnext'
  end
end, { desc = '[T]ab [N]ext (wraps to first)' })
vim.keymap.set('n', '<leader>tp', function()
  if vim.fn.tabpagenr() == 0 then
    vim.cmd 'tablast'
  else
    vim.cmd 'tabp'
  end
end, { desc = '[T]ab [P]revious (wraps to last)' })
-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Support ansible in certain folders
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*/playbooks/*.yml', '*/roles/*.yml', '*/tasks/*.yml', '*ansible*.yml', '*.yaml' },
  callback = function()
    vim.bo.filetype = 'yaml.ansible'
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufRead', 'BufNewFile' }, {
  pattern = {
    '*.html.j2',
    '*.html.jinja',
    '*.html.jinja2',
    '*.sh.j2',
    '*.sh.jinja',
    '*.sh.jinja2',
    '*.yml.j2',
    '*.yml.jinja',
    '*.yaml.j2',
    '*.yaml.jinja',
    '*.conf.j2',
    '*.conf.jinja',
    'docker-compose*.yml.j2',
    'docker-compose*.yaml.j2',
    'Dockerfile*.j2',
    '*.j2',
    '*.jinja',
    '*.jinja2',
  },
  callback = function(ev)
    local filename = vim.fn.expand '%:t'
    local base_ext = vim.fn.fnamemodify(filename:gsub('%.j2$', ''):gsub('%.jinja2?$', ''), ':e')
    local bufnr = ev.buf

    -- Try to determine the base filetype
    local base_ft = ''

    -- Check for docker-compose files first (special case)
    if filename:match '^docker%-compose' and (base_ext == 'yml' or base_ext == 'yaml') then
      base_ft = 'yaml.docker-compose'
    elseif filename:match '^Dockerfile' then
      base_ft = 'dockerfile'
    elseif base_ext == 'sh' then
      base_ft = 'sh'
    elseif base_ext == 'yml' or base_ext == 'yaml' then
      base_ft = 'yaml'
    elseif base_ext == 'html' then
      base_ft = 'html'
    elseif base_ext == 'conf' then
      base_ft = 'conf'
    end

    -- Set the appropriate filetype
    if base_ft ~= '' then
      vim.bo[bufnr].filetype = base_ft .. '.jinja'
    else
      vim.bo[bufnr].filetype = 'jinja'
    end

    -- If treesitter doesn't support jinja, ensure syntax is on
    if vim.treesitter.language.get_lang 'jinja' == nil then
      vim.bo[bufnr].syntax = 'on'
    end
  end,
  desc = 'Set correct filetype for template files with compound extensions',
})

local function set_filetype_from_quicklist()
  -- Define a list of common filetypes
  -- You can add or remove filetypes according to your needs
  local filetypes = {
    'lua',
    'python',
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
    'go',
    'rust',
    'yaml',
    'yaml.ansible',
    'json',
    'html',
    'css',
    'markdown',
    'sh',
    'bash',
    'terraform',
    'vim',
  }

  -- Create a table for vim.ui.select
  local items = {}
  for _, ft in ipairs(filetypes) do
    table.insert(items, { label = ft, value = ft })
  end

  -- Prompt the user to choose a filetype
  vim.ui.select(items, {
    prompt = 'Select filetype:',
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      vim.bo.filetype = choice.value
      print('Filetype set to: ' .. choice.value)
    end
  end)
end

-- Create a command to invoke the function
vim.api.nvim_create_user_command('SetFileType', set_filetype_from_quicklist, {
  desc = 'Set filetype from a quick list',
})

-- Create a keymap for quick access (optional)
vim.keymap.set('n', '<leader>ft', ':SetFileType<CR>', { desc = 'Set [F]ile [T]ype from list' })
--
-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- 'ThePrimeagen/vim-be-good',
  'jesseduffield/lazygit',
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  -- 'github/copilot.vim',
  'HiPhish/jinja.vim',
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
  --

  -- Alternatively, use `config = function() ... end` for full control over the configuration.
  -- If you prefer to call `setup` explicitly, use:
  --    {
  --        'lewis6991/gitsigns.nvim',
  --        config = function()
  --            require('gitsigns').setup({
  --                -- Your gitsigns configuration here
  --            })
  --        end,
  --    }
  --
  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`.
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  -- { -- Adds git related signs to the gutter, as well as utilities for managing changes
  --   'lewis6991/gitsigns.nvim',
  --   opts = {
  --     signs = {
  --       add = { text = '+' },
  --       change = { text = '~' },
  --       delete = { text = '_' },
  --       topdelete = { text = '‾' },
  --       changedelete = { text = '~' },
  --     },
  --   },
  -- },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `opts` key (recommended), the configuration runs
  -- after the plugin has been loaded as `require(MODULE).setup(opts)`.

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>f', group = '[F]ile', mode = { 'n' } },
        { '<leader>b', group = '[B]uffer', mode = { 'n' } },
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ebug, [D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]indow, [W]orkspace' },
        { '<leader>t', group = '[T]oggle, [T]ab' },
        { '<leader>g', group = '[G]o, [G]it', mode = { 'n', 'v' } },
        { '<leader>gg', group = '[G]it[G]it', mode = { 'n', 'v' } },

        { '<leader>a', group = '[A]I', mode = { 'n', 'v' } },
      },
    },
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        defaults = {
          ignore_case = true,
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
      vim.keymap.set('n', '<leader>sa', function()
        builtin.find_files { hidden = true, no_ignore = true }
      end, { desc = '[S]earch [F]iles [H]idden' })
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
      'b0o/SchemaStore.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- Find references for the word under your cursor.
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end
          map('<C-s>', vim.lsp.buf.signature_help, 'See [S]ignature', { 'i' })
          -- Toogle signature in normal mode
          map('<leader>ts', vim.lsp.buf.hover, '[T]oggle [S]ignature', { 'n' })
          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end

          -- Add custom file type handlers
          local filetype = vim.bo[event.buf].filetype
          -- print(filetype)
          local handler_path = 'config-lsp.filetype-handler.' .. filetype
          local filepath = vim.fn.stdpath 'config' .. '/lua/' .. handler_path:gsub('%.', '/') .. '.lua'
          local handler = nil

          local stat = vim.loop.fs_stat(filepath)
          if stat and stat.type == 'file' then
            handler = require(handler_path)
          end

          if handler then
            handler(event.client, event.buf)
            -- Uncomment the following line in case you want to debug a specific file
            -- else
            -- print('No specific LSP handler found for filetype: ' .. filetype) -- Optional: Log when no handler exists
          end
        end,
      })
      -- Replace your existing vim.diagnostic.config in init.lua with this:

      vim.diagnostic.config {
        severity_sort = true,

        -- Enhanced float configuration for quick viewing
        float = {
          border = 'rounded',
          source = 'if_many',
          header = '',
          prefix = '',
          max_width = 80,
          max_height = 20,
          focusable = false,
          close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
        },

        underline = { severity = vim.diagnostic.severity.ERROR },

        -- Smaller, minimal signs
        signs = vim.g.have_nerd_font
            and {
              text = {
                [vim.diagnostic.severity.ERROR] = '●', -- Small filled circle
                [vim.diagnostic.severity.WARN] = '●', -- Small filled circle
                [vim.diagnostic.severity.INFO] = '●', -- Small filled circle
                [vim.diagnostic.severity.HINT] = '●', -- Small filled circle
              },
            }
          or {
            text = {
              [vim.diagnostic.severity.ERROR] = 'E',
              [vim.diagnostic.severity.WARN] = 'W',
              [vim.diagnostic.severity.INFO] = 'I',
              [vim.diagnostic.severity.HINT] = 'H',
            },
          },

        -- Subtle virtual text with colors
        virtual_text = {
          spacing = 2,
          prefix = '',
          format = function(diagnostic)
            -- Show first 25 characters in a subtle way
            local message = diagnostic.message:gsub('\n', ' ') -- Remove newlines
            local truncated = string.sub(message, 1, 25)
            if #message > 25 then
              truncated = truncated .. '…'
            end
            return truncated
          end,
        },
      }

      -- Add convenient keymaps for diagnostic float
      vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { desc = '[D]iagnostic [D]isplay float' })
      vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = '[D]iagnostic [L]ist' })

      -- Subtle, colored diagnostic highlights (not yelling)
      vim.api.nvim_set_hl(0, 'DiagnosticSignError', { fg = '#e06c75' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { fg = '#e5c07b' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', { fg = '#61afef' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignHint', { fg = '#98c379' })

      -- Subtle virtual text colors (more muted than signs)
      vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextError', { fg = '#e06c75', italic = true, blend = 20 })
      vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextWarn', { fg = '#e5c07b', italic = true, blend = 20 })
      vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextInfo', { fg = '#61afef', italic = true, blend = 20 })
      vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextHint', { fg = '#98c379', italic = true, blend = 20 })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  when you add nvim-cmp, luasnip, etc. neovim now has *more* capabilities.
      --  so, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- enable the following language servers
      --  feel free to add/remove any lsps that you want here. they will automatically be installed.
      --
      --  add any additional override configuration in the following tables. available keys are:
      --  - cmd (table): override the default command used to start the server
      --  - filetypes (table): override the default list of associated filetypes for the server
      --  - capabilities (table): override fields in capabilities. can be used to disable certain lsp features.
      --  - settings (table): override the default settings passed when initializing the server.
      --        for example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. see `:help lspconfig-all` for a list of all the pre-configured lsps
        --
        -- some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- but for many setups, the lsp (`ts_ls`) will work just fine
        -- ts_ls = {},
        eslint = {
          on_attach = function(_, bufnr)
            vim.keymap.set('n', '<leader>ef', function()
              vim.cmd 'EslintFixAll'
              -- Optionally format with Prettier after ESLint fixes
            end, {
              buffer = bufnr,
              desc = '[E]slint [F]ix all',
            })
          end,
          settings = {
            -- Enhanced settings
            packageManager = 'npm', -- or 'yarn', 'pnpm'
            useESLintClass = true, -- For newer ESLint
            experimental = {
              useFlatConfig = false, -- Set to true if using ESLint flat config
            },
            quiet = false,
            onIgnoredFiles = 'warn',
            rulesCustomizations = {},
            run = 'onType', -- or 'onSave'
            problems = {
              shortenToSingleLine = false,
            },

            codeAction = {
              disableRuleComment = {
                enable = true,
                location = 'separateLine',
              },
              showDocumentation = {
                enable = true,
              },
            },

            -- Advanced: specify workspaces/workspace folders configuration
            workingDirectories = {
              { mode = 'auto' }, -- auto-detect based on package.json or .eslintrc
            },
          },
        },
        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            lua = {
              completion = {
                callsnippet = 'replace',
              },
              -- you can toggle below to ignore lua_ls's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        pyright = {
          settings = {
            pyright = {
              -- Using Ruff's import organizer
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for linting
                ignore = { '*' },
              },
            },
          },
        },
        bashls = {},
        gopls = {},
        terraformls = {},
        ansiblels = {
          filetypes = { 'yaml.ansible', 'ansible' },
        },
        dockerls = {},
        ruff = {},
        docker_compose_language_service = {
          filetypes = { 'docker-compose', 'docker-compose.jinja' },
        },
        jinja_lsp = {},
        html = {},
        jsonls = {
          settings = {
            json = {
              -- Use schemastore to get schemas for common JSON files
              schemas = require('schemastore').json.schemas(),
              -- Configure json validation and schema mapping
              validate = { enable = true },
            },
          },
        },
      }

      -- ensure the servers and tools above are installed
      --
      -- to check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :mason
      --
      -- you can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- you can add other tools here that you want mason to install
      -- for you, so that they are available from within neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- used to format lua code
        'eslint_d',
        'prettierd',
        'prettier',
        'revive', -- Go linter
        'gofumpt', -- Go formatter
        'goimports', -- Go imports formatter
        'golangci-lint', -- Comprehensive Go linting
        'ansible-lint',
        -- Python tools
        'ruff',
        'isort', -- Python import sorter
        'debugpy',
        -- Bash
        'shfmt',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default', -- Use the default preset

        -- Disable Tab for blink.cmp (let Copilot handle it)
        ['<Tab>'] = {},

        -- Keep Shift-Tab for snippet navigation
        -- (this is already in default preset, but being explicit)
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      },

      appearance = {
        nerd_font_variant = 'mono',
      },

      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        accept = {
          auto_brackets = {
            enabled = false, -- Disable to avoid conflicts with autopairs
          },
        },
        menu = {
          draw = {
            columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } },
          },
        },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      snippets = {
        preset = 'luasnip',
      },

      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        style = 'night',
        styles = {
          comments = { italic = false }, -- Disable italics in comments
          sidebars = 'transparent', -- Make sidebars transparent
          floats = 'transparent', -- Make floating windows transparent
        },
        transparent = true, -- Enable transparency
        terminal_colors = true, -- Enable terminal colors
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup {
        use_icons = vim.g.have_nerd_font,
      }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps
  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- Updated functions for copilot.lua compatibility
local function copilot_suggestion_visible()
  local ok, copilot = pcall(require, 'copilot.suggestion')
  if not ok then
    return false
  end
  return copilot.is_visible()
end

-- Enhanced function to check snippet state
local function can_jump_snippet(direction)
  local ok, luasnip = pcall(require, 'luasnip')
  if not ok then
    return false
  end
  return luasnip.jumpable(direction or 1)
end

-- Check if we're in a chat buffer
local function is_chat_buffer()
  local buf_ft = vim.bo.filetype
  local buf_name = vim.api.nvim_buf_get_name(0)
  return buf_ft == 'copilot-chat' or buf_name:match 'copilot%-chat'
end

-- Smart Tab - Updated for copilot.lua compatibility
vim.keymap.set('i', '<Tab>', function()
  -- Special handling for chat buffers
  if is_chat_buffer() then
    -- 1. First priority: Copilot suggestion in chat
    if copilot_suggestion_visible() then
      local ok, copilot = pcall(require, 'copilot.suggestion')
      if ok then
        copilot.accept()
        return
      end
    end

    -- 2. Check for completion menu in chat
    if vim.fn.pumvisible() == 1 then
      return '<C-n>'
    end

    -- 3. Fallback to regular tab in chat
    return '<Tab>'
  end

  -- Regular buffers (non-chat)
  -- 1. First priority: Copilot suggestion
  if copilot_suggestion_visible() then
    local ok, copilot = pcall(require, 'copilot.suggestion')
    if ok then
      copilot.accept()
      return
    end
  end

  -- 2. Second priority: Snippet jumping
  if can_jump_snippet(1) then
    require('luasnip').jump(1)
    return
  end

  -- 3. Fallback: Regular tab
  return '<Tab>'
end, { expr = true, silent = true, desc = 'Smart Tab: Copilot -> Snippet -> Tab' })

-- Keep your existing snippet controls
vim.keymap.set('i', '<C-l>', function()
  local luasnip = require 'luasnip'
  if luasnip.jumpable(1) then
    luasnip.jump(1)
    print 'Jumped to next snippet placeholder'
  else
    print 'No next snippet placeholder available'
  end
end, { desc = 'Force snippet forward' })

vim.keymap.set('i', '<C-h>', function()
  local luasnip = require 'luasnip'
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
    print 'Jumped to previous snippet placeholder'
  else
    print 'No previous snippet placeholder available'
  end
end, { desc = 'Force snippet backward' })

-- Shift-Tab for snippet backward (as backup)
vim.keymap.set('i', '<S-Tab>', function()
  local luasnip = require 'luasnip'
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
    return
  end
  return '<S-Tab>'
end, { expr = true, silent = true, desc = 'Snippet backward' })

-- Enhanced debug command
vim.keymap.set('n', '<leader>td', function()
  local luasnip = require 'luasnip'

  print '=== Debug Info ==='
  print('Buffer type:', vim.bo.filetype)
  print('Is chat buffer:', is_chat_buffer())
  print('Copilot visible:', copilot_suggestion_visible())
  print('In snippet:', luasnip.in_snippet())
  print('Can jump forward:', luasnip.jumpable(1))
  print('Can jump backward:', luasnip.jumpable(-1))
  print('Locally jumpable forward:', luasnip.locally_jumpable(1))
  print('Locally jumpable backward:', luasnip.locally_jumpable(-1))

  if luasnip.in_snippet() then
    local snippet = luasnip.get_active_snip()
    if snippet then
      print('Active snippet:', snippet.trigger or 'unknown')
    end
  end

  -- Test Copilot
  local ok, copilot = pcall(require, 'copilot.suggestion')
  if ok then
    print('Copilot module loaded:', true)
  else
    print('Copilot module error:', copilot)
  end

  print '=================='
end, { desc = '[T]ab [D]ebug info' })
