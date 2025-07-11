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
      return {
        model = 'gpt-4.1',
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

      -- Setup AI modules with error handling
      local function setup_ai_modules()
        local ok_keymaps, keymaps_err = pcall(require, 'custom.ai.keymaps')
        local ok_commands, commands_err = pcall(require, 'custom.ai.commands')
        local ok_models, models_err = pcall(require, 'custom.ai.models')

        if not ok_keymaps then
          vim.notify('AI keymaps failed to load: ' .. tostring(keymaps_err), vim.log.levels.ERROR)
          return
        end

        if not ok_commands then
          vim.notify('AI commands failed to load: ' .. tostring(commands_err), vim.log.levels.ERROR)
          return
        end

        if not ok_models then
          vim.notify('AI models failed to load: ' .. tostring(models_err), vim.log.levels.ERROR)
          return
        end

        -- Setup modules
        local ok_setup_keymaps = pcall(require('custom.ai.keymaps').setup)
        if not ok_setup_keymaps then
          vim.notify('Failed to setup AI keymaps', vim.log.levels.ERROR)
        end

        local ok_setup_commands = pcall(require('custom.ai.commands').setup)
        if not ok_setup_commands then
          vim.notify('Failed to setup AI commands', vim.log.levels.ERROR)
        end

        vim.notify('AI modules loaded successfully', vim.log.levels.INFO)
      end

      -- Delay setup to ensure all dependencies are loaded
      vim.defer_fn(setup_ai_modules, 1000)

      -- Setup autocmds
      vim.api.nvim_create_autocmd('User', {
        pattern = 'CopilotChatOpen',
        callback = function()
          vim.defer_fn(function()
            local ok_models, models = pcall(require, 'custom.ai.models')
            if ok_models then
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
            end
          end, 100)
        end,
      })

      -- Basic fallback keymaps in case modules fail
      vim.keymap.set('n', '<leader>aa', '<cmd>CopilotChatToggle<CR>', { desc = '[A]I Toggle Chat' })
      vim.keymap.set('n', '<leader>ar', '<cmd>CopilotChatReset<CR>', { desc = '[A]I Reset Chat' })

      -- Emergency fix keymap
      vim.keymap.set({ 'n', 'v' }, '<F2>', function()
        require('CopilotChat').ask 'Fix the issues in this code. Be concise and focus on the actual problem.'
      end, { desc = 'AI Quick Fix' })

      -- Emergency help keymap
      vim.keymap.set('n', '<F1>', function()
        require('CopilotChat').ask 'Explain this code clearly and concisely. Focus on what it does and why.'
      end, { desc = 'AI Quick Help' })
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
