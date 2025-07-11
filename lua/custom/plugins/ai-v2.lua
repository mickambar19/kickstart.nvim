return {
  -- GitHub Copilot for completions
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = '[[',
            jump_next = ']]',
            accept = '<CR>',
            refresh = 'gr',
            open = '<M-p>',
          },
          layout = {
            position = 'bottom',
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          debounce = 75,
          keymap = {
            accept = false, -- Use CopilotChat for accepting suggestions
            accept_word = '<M-w>',
            accept_line = '<M-l>',
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-]>',
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          ['.'] = false,
          ['copilot-chat'] = true,
        },
      }

      -- Toggle Copilot
      vim.keymap.set('n', '<leader>aot', function()
        require('copilot.suggestion').toggle_auto_trigger()
        local status = require('copilot.suggestion').is_visible() and 'enabled' or 'disabled'
        vim.notify('Copilot auto-trigger ' .. status, vim.log.levels.INFO)
      end, { desc = '[AI] Toggle Copilot' })
    end,
  },

  -- CopilotChat with enhanced workflow
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    dependencies = {
      'github/copilot.vim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    build = 'make tiktoken',
    opts = function()
      -- Load AI modules
      local ai_core = require 'custom.ai.core'
      local ai_models = require 'custom.ai.models'

      return {
        model = ai_models.get_current_model(),
        window = {
          layout = 'vertical',
          width = 0.4,
          height = 0.6,
          relative = 'editor',
          border = 'rounded',
        },
        auto_follow_cursor = true,
        auto_insert_mode = false,
        mappings = {
          complete = { insert = false },
          close = { normal = 'q', insert = '<Esc>' },
          reset = { normal = '<C-x>' },
          submit_prompt = { normal = '<CR>', insert = '<C-m>' },
          accept_diff = { normal = '<C-y>', insert = '<C-y>' },
          yank_diff = { normal = 'gy' },
          show_diff = { normal = 'gd' },
        },
      }
    end,
    config = function(_, opts)
      require('CopilotChat').setup(opts)

      -- Load all AI modules
      local ai_core = require 'custom.ai.core'
      local ai_keymaps = require 'custom.ai.keymaps'
      local ai_commands = require 'custom.ai.commands'

      -- Setup keymaps and commands
      ai_keymaps.setup()
      ai_commands.setup()

      -- Setup autocmds
      vim.api.nvim_create_autocmd('User', {
        pattern = 'CopilotChatOpen',
        callback = function()
          vim.defer_fn(function()
            local models = require 'custom.ai.models'
            local current = models.get_current_model()
            local usage = models.get_usage_info()

            vim.notify(
              string.format(
                [[
AI Assistant Ready (%s)
%s
• <C-y> = Apply changes
• <leader>am = Switch model
• <leader>a = Quick actions]],
                current,
                usage
              ),
              vim.log.levels.INFO
            )
          end, 1000)
        end,
      })
    end,
    cmd = {
      'CopilotChat',
      'AI',
      'AIFix',
      'AICommit',
      'AIReview',
      'AITest',
      'AIDocs',
      'AIUsage',
    },
    keys = {
      { '<leader>a', desc = '+AI Assistant', mode = { 'n', 'v' } },
      { '<F1>', desc = 'AI Help' },
      { '<F2>', desc = 'AI Fix' },
    },
  },
}
