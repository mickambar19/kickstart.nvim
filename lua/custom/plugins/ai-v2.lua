return {
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
            accept = '<C-j>',
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

      vim.keymap.set('n', '<leader>aot', function()
        require('copilot.suggestion').toggle_auto_trigger()
        local status = require('copilot.suggestion').is_visible() and 'enabled' or 'disabled'
        vim.notify('Copilot auto-trigger ' .. status, vim.log.levels.INFO)
      end, { desc = '[AI] Toggle Copilot' })
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    build = 'make tiktoken',
    opts = function()
      return {
        model = 'claude-sonnet-4',
        max_tokens = 4000,
        temperature = 0.1,

        window = {
          layout = 'vertical',
          width = 0.5,
          height = 0.8,
          relative = 'editor',
          border = 'rounded',
        },

        auto_follow_cursor = true,
        auto_insert_mode = false,
        clear_chat_on_new_prompt = false,

        system_prompt = [[You are an AI programming assistant. 
When generating code, especially tests, provide complete, working examples.
Always finish your responses completely - never truncate code blocks or explanations.
If a response would be very long, break it into logical sections but complete each section.]],

        mappings = {
          complete = { insert = '<C-j>' },
          close = { normal = 'q', insert = '<Esc>' },
          reset = { normal = '<C-x>' },
          submit_prompt = { normal = '<CR>', insert = '<C-m>' },
          accept_diff = { normal = '<C-y>', insert = '<C-y>' },
          yank_diff = { normal = 'gy' },
          show_diff = { normal = 'gd' },
          continue_response = { normal = '<C-n>' },
        },

        callback = function(response, source)
          if response and (response:match '```[^`]*$' or response:match '%.%.%.$' or response:match '[^%.]$' and #response > 500) then
            vim.notify('Response may be truncated. Press <C-n> to continue.', vim.log.levels.WARN)
          end
        end,
      }
    end,

    config = function(_, opts)
      require('CopilotChat').setup(opts)

      vim.api.nvim_create_user_command('ContinueResponse', function()
        require('CopilotChat').ask 'Continue the previous response from where it was cut off. Complete any unfinished code blocks or explanations.'
      end, { desc = 'Continue truncated AI response' })

      local function setup_ai_modules()
        local modules = {
          { name = 'keymaps', path = 'custom.ai.keymaps' },
          { name = 'commands', path = 'custom.ai.commands' },
          { name = 'models', path = 'custom.ai.models' },
        }

        local loaded_modules = {}
        local failed_modules = {}

        -- Load all modules first
        for _, module in ipairs(modules) do
          local ok, mod = pcall(require, module.path)
          if ok then
            loaded_modules[module.name] = mod
          else
            table.insert(failed_modules, { name = module.name, error = mod })
          end
        end

        -- Report any failures
        if #failed_modules > 0 then
          local error_msg = 'Failed to load AI modules:\n'
          for _, fail in ipairs(failed_modules) do
            error_msg = error_msg .. '  • ' .. fail.name .. ': ' .. fail.error .. '\n'
          end
          vim.notify(error_msg, vim.log.levels.ERROR)
          return
        end

        -- Setup modules if all loaded successfully
        local setup_success = {}
        for name, mod in pairs(loaded_modules) do
          if mod.setup then
            local ok, err = pcall(mod.setup)
            if not ok then
              vim.notify('Failed to setup ' .. name .. ': ' .. err, vim.log.levels.ERROR)
            else
              table.insert(setup_success, name)
            end
          end
        end

        if #setup_success > 0 then
          vim.notify('AI modules loaded: ' .. table.concat(setup_success, ', '), vim.log.levels.INFO)
        end
      end

      vim.defer_fn(setup_ai_modules, 1000)

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
                  [[AI Assistant Ready (%s)
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

      vim.keymap.set('n', '<leader>aa', '<cmd>CopilotChatToggle<CR>', { desc = '[A]I Toggle Chat' })
      vim.keymap.set('n', '<leader>ar', '<cmd>CopilotChatReset<CR>', { desc = '[A]I Reset Chat' })

      vim.keymap.set({ 'n', 'v' }, '<F2>', function()
        require('CopilotChat').ask 'Fix the issues in this code. Be concise and focus on the actual problem.'
      end, { desc = 'AI Quick Fix' })

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
