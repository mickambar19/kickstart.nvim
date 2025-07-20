return {
  -- Enhanced Copilot with optimized settings
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
            position = 'right',
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          debounce = 50, -- Optimized for speed
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
          yaml = true,
          markdown = true,
          help = false,
          gitcommit = true,
          gitrebase = true,
          ['.'] = false,
          ['copilot-chat'] = false,
        },
      }

      -- Enhanced suggestion styling
      vim.api.nvim_set_hl(0, 'CopilotSuggestion', {
        fg = '#6B7280',
        italic = true,
        blend = 20,
      })

      -- Toggle functionality
      vim.keymap.set('n', '<leader>tc', function()
        require('copilot.suggestion').toggle_auto_trigger()
        local enabled = require('copilot.suggestion').is_visible()
        vim.notify('Copilot ' .. (enabled and 'enabled' or 'disabled'), vim.log.levels.INFO)
      end, { desc = '[T]oggle [C]opilot suggestions' })
    end,
  },

  -- Advanced CopilotChat with workspace integration
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    dependencies = {
      'nvim-telescope/telescope-live-grep-args.nvim',
    },
    build = 'make tiktoken',
    config = function()
      local telescope = require 'telescope'

      -- Enhanced telescope for AI context
      pcall(telescope.load_extension, 'live_grep_args')

      -- AI-specific telescope commands
      vim.keymap.set('n', '<leader>asp', function()
        local ok, live_grep_args = pcall(telescope.extensions.live_grep_args.live_grep_args)
        if ok then
          live_grep_args {
            prompt_title = 'AI Ultra: Search Project for Context',
            default_text = '',
          }
        else
          require('telescope.builtin').live_grep {
            prompt_title = 'AI Ultra: Search Project for Context',
          }
        end
      end, { desc = '[A]I [S]earch [P]roject for context' })
      -- Load AI Ultra modules
      local modules = {}
      local module_names = { 'core', 'models', 'workflows', 'prompts', 'keymaps', 'commands', 'workspace' }

      -- Safe module loading with fallbacks
      for _, name in ipairs(module_names) do
        print(name)
        local ok, module = pcall(require, 'custom.ai-ultra.' .. name)
        if ok then
          modules[name] = module
          vim.notify('✅ AI Ultra: ' .. name .. ' loaded', vim.log.levels.DEBUG)
        else
          vim.notify('⚠️ AI Ultra: Failed to load ' .. name .. ' - ' .. module, vim.log.levels.WARN)
          modules[name] = nil
        end
      end

      -- Get current model with fallback
      local current_model = 'claude-sonnet-4'
      if modules.models then
        current_model = modules.models.get_current_model()
      end

      -- Enhanced CopilotChat setup
      require('CopilotChat').setup {
        model = current_model,
        max_tokens = 4000,
        temperature = 0.1,

        -- Enhanced system prompt with context awareness
        system_prompt = [[You are an expert AI programming assistant integrated into Neovim.

You have access to:
- Complete project structure and context
- Git repository information and history  
- File relationships and dependencies
- Current diagnostics and LSP information
- Framework and language-specific patterns

Guidelines:
1. Always provide complete, working code examples
2. Never truncate responses - finish all code blocks and explanations
3. Consider project patterns and existing architecture
4. Prioritize security, performance, and maintainability
5. Include comprehensive error handling
6. Provide testing strategies and examples

When generating code:
- Follow the project's existing patterns and style
- Consider the full context, not just the current file
- Suggest improvements that align with best practices
- Include relevant documentation and comments]],

        -- Enhanced window configuration
        window = {
          layout = 'float',
          width = 0.85,
          height = 0.85,
          relative = 'editor',
          border = 'rounded',
          row = 1,
          col = 1,
          title = ' AI Ultra Assistant ',
          title_pos = 'center',
        },

        auto_follow_cursor = true,
        auto_insert_mode = false,
        clear_chat_on_new_prompt = false,

        -- Enhanced mappings
        mappings = {
          complete = { insert = '<C-j>' },
          close = { normal = 'q', insert = '<Esc>' },
          reset = { normal = '<C-x>' },
          submit_prompt = { normal = '<CR>', insert = '<C-m>' },
          accept_diff = { normal = '<C-y>', insert = '<C-y>' },
          yank_diff = { normal = 'gy' },
          show_diff = { normal = 'gd' },
          continue_response = { normal = '<C-n>' },
          regenerate = { normal = '<C-r>' },
          insert_at_cursor = { normal = '<C-i>' },
        },

        -- Anti-truncation callback
        callback = function(response, source)
          if response then
            -- Detect potential truncation
            local is_truncated = response:match '```[^`]*$' or response:match '%.%.%.$' or (response:len() > 1000 and not response:match '[.!?]%s*$')

            if is_truncated then
              vim.schedule(function()
                vim.notify('⚠️ Response may be truncated. Use <C-n> to continue.', vim.log.levels.WARN)
              end)
            end
          end

          -- Track usage if models module is available
          if modules.models and source then
            modules.models.track_usage()
          end
        end,

        -- Enhanced context selection
        selection = function(source)
          if modules.core then
            return modules.core.smart_selection()(source)
          else
            return require('CopilotChat.select').visual(source) or require('CopilotChat.select').buffer(source)
          end
        end,
      }

      -- Setup AI Ultra modules with error handling
      local setup_modules = function()
        local success_count = 0

        -- Setup each module
        for name, module in pairs(modules) do
          if module and module.setup then
            local ok, err = pcall(module.setup)
            if ok then
              success_count = success_count + 1
              vim.notify('🚀 AI Ultra: ' .. name .. ' initialized', vim.log.levels.DEBUG)
            else
              vim.notify('❌ AI Ultra: Failed to setup ' .. name .. ' - ' .. err, vim.log.levels.ERROR)
            end
          end
        end

        -- Final status
        if success_count > 0 then
          local model_info = modules.models and modules.models.get_usage_info() or 'Model info unavailable'
          vim.notify(string.format('🤖 AI Ultra Ready! (%d/%d modules) - %s', success_count, vim.tbl_count(modules), model_info), vim.log.levels.INFO)
        else
          vim.notify('⚠️ AI Ultra: Basic functionality only (modules failed to load)', vim.log.levels.WARN)
        end
      end

      -- Delayed module setup to ensure all dependencies are loaded
      vim.defer_fn(setup_modules, 1000)

      -- Auto-inject workspace context on chat open
      vim.api.nvim_create_autocmd('User', {
        pattern = 'CopilotChatOpen',
        callback = function()
          if modules.workspace then
            vim.defer_fn(function()
              local context = modules.workspace.get_project_context()
              if context then
                local context_lines = {
                  '=== Project Context ===',
                  'Type: ' .. (context.project_type or 'unknown'),
                  'Files: ' .. (context.git_root and vim.fn.expand(context.git_root) or 'unknown'),
                  'Branch: ' .. vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', ''),
                  '=======================',
                  '',
                }

                -- Add context to chat
                local buf = vim.api.nvim_get_current_buf()
                if vim.api.nvim_buf_is_valid(buf) then
                  vim.api.nvim_buf_set_lines(buf, 0, 0, false, context_lines)
                end
              end
            end, 200)
          end
        end,
      })

      -- Essential keymaps (even if keymaps module fails)
      vim.keymap.set('n', '<leader>aa', '<cmd>CopilotChatToggle<CR>', { desc = '[A]I [A]ctivate chat' })
      vim.keymap.set('n', '<leader>az', '<cmd>CopilotChatReset<CR>', { desc = '[A]I [Z]ero/reset chat' })

      -- Emergency AI help (always available)
      vim.keymap.set({ 'n', 'v' }, '<leader>ae', function()
        if modules.core then
          modules.core.quick_action 'explain'
        else
          require('CopilotChat').ask 'Explain this code clearly and comprehensively.'
        end
      end, { desc = '[A]I [E]xplain (emergency)' })

      vim.keymap.set({ 'n', 'v' }, '<leader>af', function()
        if modules.core then
          modules.core.quick_action 'fix'
        else
          require('CopilotChat').ask 'Fix any issues in this code and explain the fixes.'
        end
      end, { desc = '[A]I [F]ix (emergency)' })
    end,

    cmd = {
      'CopilotChat',
      'CopilotChatOpen',
      'CopilotChatToggle',
      'CopilotChatReset',
      -- AI Ultra commands will be added by commands module
    },

    keys = {
      { '<leader>a', desc = '+AI Ultra Assistant', mode = { 'n', 'v' } },
      { '<leader>aa', desc = 'AI Activate Chat' },
      { '<leader>ae', desc = 'AI Explain' },
      { '<leader>af', desc = 'AI Fix' },
      -- Additional keys will be added by keymaps module
    },
  },
}
