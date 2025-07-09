return {
  -- GitHub Copilot for completions
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    config = function()
      vim.g.copilot_no_tab_map = true

      -- Fast completion keymaps
      vim.keymap.set('i', '<C-j>', 'copilot#Accept("")', {
        expr = true,
        replace_keycodes = false,
        desc = 'Accept Copilot suggestion',
      })

      vim.keymap.set('i', '<C-l>', '<Plug>(copilot-accept-word)', {
        desc = 'Accept Copilot word',
      })

      vim.keymap.set('i', '<C-n>', '<Plug>(copilot-next)', {
        desc = 'Next Copilot suggestion',
      })

      vim.keymap.set('i', '<C-p>', '<Plug>(copilot-previous)', {
        desc = 'Previous Copilot suggestion',
      })
    end,
  },

  -- CopilotChat with better keymaps
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    dependencies = {
      { 'github/copilot.vim' },
      { 'nvim-lua/plenary.nvim' },
    },
    build = 'make tiktoken',
    opts = {
      debug = false,
      window = {
        layout = 'vertical',
        width = 0.4,
        height = 0.5,
        relative = 'editor',
        border = 'rounded',
      },
      auto_follow_cursor = true,
      auto_insert_mode = false,
      mappings = {
        complete = {
          detail = 'Use @<Tab> or /<Tab> for options.',
          insert = '<Tab>',
        },
        close = {
          normal = 'q',
          insert = '<C-c>',
        },
        reset = {
          normal = '<C-x>',
          insert = '<C-x>',
        },
        submit_prompt = {
          normal = '<CR>',
          insert = '<C-CR>',
        },
        accept_diff = {
          normal = '<C-y>',
          insert = '<C-y>',
        },
        yank_diff = {
          normal = 'gy',
        },
        show_diff = {
          normal = 'gd',
        },
      },
    },
    config = function(_, opts)
      require('CopilotChat').setup(opts)

      -- AI prefix for all AI-related operations
      -- Using <leader>a for AI (no conflicts with your setup)
      local keymap = vim.keymap.set

      -- Primary chat operations (fast access)
      keymap({ 'n', 'v' }, '<leader>aa', function()
        require('CopilotChat').toggle()
      end, { desc = '[A]I Ch[a]t Toggle' })

      keymap({ 'n', 'v' }, '<leader>aq', function()
        local input = vim.fn.input 'Quick Chat: '
        if input ~= '' then
          require('CopilotChat').ask(input)
        end
      end, { desc = '[A]I [Q]uick chat' })

      -- Visual mode operations (context-aware)
      keymap('v', '<leader>ae', ':CopilotChatExplain<CR>', { desc = '[A]I [E]xplain' })
      keymap('v', '<leader>ar', ':CopilotChatReview<CR>', { desc = '[A]I [R]eview' })
      keymap('v', '<leader>af', ':CopilotChatFix<CR>', { desc = '[A]I [F]ix' })
      keymap('v', '<leader>ao', ':CopilotChatOptimize<CR>', { desc = '[A]I [O]ptimize' })
      keymap('v', '<leader>ad', ':CopilotChatDocs<CR>', { desc = '[A]I [D]ocument' })
      keymap('v', '<leader>at', ':CopilotChatTests<CR>', { desc = '[A]I [T]ests' })

      -- Buffer operations
      keymap('n', '<leader>ab', function()
        require('CopilotChat').ask('Explain this file', {
          selection = require('CopilotChat.select').buffer,
        })
      end, { desc = '[A]I [B]uffer chat' })

      -- Inline operations (floating window at cursor)
      keymap({ 'n', 'v' }, '<leader>ai', function()
        require('CopilotChat').ask('', {
          selection = require('CopilotChat.select').visual,
          window = {
            layout = 'float',
            relative = 'cursor',
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { desc = '[A]I [I]nline' })

      -- Advanced operations
      keymap('n', '<leader>ap', function()
        local actions = require 'CopilotChat.actions'
        require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
      end, { desc = '[A]I [P]rompt actions' })

      keymap('n', '<leader>ah', function()
        local actions = require 'CopilotChat.actions'
        require('CopilotChat.integrations.telescope').pick(actions.help_actions())
      end, { desc = '[A]I [H]elp' })

      -- Git operations
      keymap('n', '<leader>ag', ':CopilotChatCommit<CR>', { desc = '[A]I [G]it commit' })
      keymap('n', '<leader>aG', ':CopilotChatCommitStaged<CR>', { desc = '[A]I [G]it commit staged' })

      -- Reset/Clear
      keymap('n', '<leader>ax', function()
        require('CopilotChat').reset()
      end, { desc = '[A]I Reset chat' })

      -- Quick diagnostic fix
      keymap('n', '<leader>aD', function()
        require('CopilotChat').ask('Please fix the diagnostic issue', {
          selection = require('CopilotChat.select').diagnostics,
        })
      end, { desc = '[A]I Fix [D]iagnostics' })

      -- Custom commands
      vim.api.nvim_create_user_command('CopilotChatVisual', function(args)
        require('CopilotChat').ask(args.args, { selection = require('CopilotChat.select').visual })
      end, { nargs = '*', range = true })

      vim.api.nvim_create_user_command('CopilotChatInline', function(args)
        require('CopilotChat').ask(args.args, {
          selection = require('CopilotChat.select').visual,
          window = {
            layout = 'float',
            relative = 'cursor',
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { nargs = '*', range = true })
    end,
    -- Lazy load on any AI command
    keys = {
      { '<leader>a', desc = '+[A]I', mode = { 'n', 'v' } },
    },
  },

  -- Optional: Add which-key group
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>a', group = '[A]I Assistant', mode = { 'n', 'v' } },
      },
    },
  },
}
