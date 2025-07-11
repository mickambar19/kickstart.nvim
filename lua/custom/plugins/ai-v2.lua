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
            open = '<M-p>', -- Alt+p to open panel
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
            accept = '<M-a>', -- Alt+a to accept full suggestion
            accept_word = '<M-w>', -- Alt+w to accept word
            accept_line = '<M-l>', -- Alt+l to accept line
            next = '<M-]>', -- Alt+] for next suggestion
            prev = '<M-[>', -- Alt+[ for previous suggestion
            dismiss = '<M-d>', -- Alt+d to dismiss suggestion
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ['.'] = false,
        },
        copilot_node_command = 'node',
        server_opts_overrides = {},
      }

      -- Additional useful keybindings
      local keymap = vim.keymap.set

      -- Toggle Copilot on/off
      keymap('n', '<leader>aof', function()
        require('copilot.suggestion').toggle_auto_trigger()
        local status = require('copilot.suggestion').is_visible() and 'enabled' or 'disabled'
        vim.notify('Copilot auto-trigger ' .. status, vim.log.levels.INFO)
      end, { desc = '[AI] [off]' })

      -- Manual trigger for suggestions
      keymap('i', '<M-s>', function()
        require('copilot.suggestion').next()
      end, { desc = 'AI Manual [S]uggest' })

      -- Status command
      keymap('n', '<leader>aistatus', '<cmd>Copilot status<CR>', { desc = '[AI] [status]' })
    end,
  },

  -- CopilotChat with workflow optimization
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    dependencies = { 'github/copilot.vim', 'nvim-lua/plenary.nvim' },
    build = 'make tiktoken',
    opts = {
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
        complete = { insert = '<Tab>' },
        close = { normal = 'q', insert = '<Esc>' },
        reset = { normal = '<C-x>' },
        submit_prompt = { normal = '<CR>', insert = '<C-m>' },
        accept_diff = { normal = '<C-y>', insert = '<C-y>' },
        yank_diff = { normal = 'gy' },
        show_diff = { normal = 'gd' },
      },
    },
    config = function(_, opts)
      require('CopilotChat').setup(opts)

      -- ============================================================================
      -- AI HELPER FUNCTIONS
      -- ============================================================================

      local ai = {}

      -- Smart context detection
      function ai.smart_selection()
        if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
          return require('CopilotChat.select').visual
        end

        local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })
        if #diagnostics > 0 then
          return require('CopilotChat.select').diagnostics
        end

        return require('CopilotChat.select').buffer
      end

      -- Instant fix with smart context
      function ai.instant_fix()
        require('CopilotChat').ask('/COPILOT_FIX', {
          selection = ai.smart_selection(),
        })
      end

      -- Instant explain with smart context
      function ai.instant_explain()
        require('CopilotChat').ask('/COPILOT_EXPLAIN', {
          selection = ai.smart_selection(),
        })
      end

      -- Instant optimize with smart context
      function ai.instant_optimize()
        require('CopilotChat').ask('/COPILOT_OPTIMIZE', {
          selection = ai.smart_selection(),
        })
      end

      -- Generate tests in new buffer
      function ai.generate_tests()
        require('CopilotChat').ask('/COPILOT_TESTS', {
          selection = ai.smart_selection(),
        })
      end

      -- Add documentation
      function ai.add_docs()
        require('CopilotChat').ask('/COPILOT_DOCS', {
          selection = ai.smart_selection(),
        })
      end

      -- Smart commit with approval
      function ai.smart_commit()
        local staged_diff = vim.fn.system 'git diff --cached'
        local auto_staged = false

        if staged_diff == '' then
          -- Auto-stage current file
          local current_file = vim.fn.expand '%'
          if current_file ~= '' then
            vim.fn.system('git add ' .. vim.fn.shellescape(current_file))
            staged_diff = vim.fn.system 'git diff --cached'
            auto_staged = true
          end
        end

        if staged_diff == '' then
          vim.notify('No changes to commit', vim.log.levels.WARN)
          return
        end

        local prompt = string.format(
          [[
Generate ONLY a commit message for these changes. 
Format: type: description
No explanation, just the commit message:

%s]],
          staged_diff
        )

        require('CopilotChat').ask(prompt, {
          callback = function(response)
            -- Extract the commit message
            local commit_msg = response:match '^[%s]*([^\n]+)' or response:match '([^\n]+)'
            if commit_msg and #commit_msg > 5 then
              -- Clean up the message
              commit_msg = commit_msg:gsub('^["\']', ''):gsub('["\']$', ''):gsub('^%s+', ''):gsub('%s+$', '')

              vim.schedule(function()
                -- Show commit message and ask for approval
                local staged_files = vim.fn.system('git diff --cached --name-only'):gsub('\n$', '')
                local auto_staged_note = auto_staged and ' (auto-staged current file)' or ''

                local confirmation = vim.fn.confirm(
                  string.format('Commit with this message?\n\n"%s"\n\nFiles%s:\n%s', commit_msg, auto_staged_note, staged_files),
                  '&Yes\n&No\n&Edit\n&Show diff',
                  1
                )

                if confirmation == 1 then
                  -- Yes - commit with AI message
                  local escaped_msg = vim.fn.shellescape(commit_msg)
                  local result = vim.fn.system('git commit -m ' .. escaped_msg)
                  if vim.v.shell_error == 0 then
                    vim.notify('✅ Committed: ' .. commit_msg, vim.log.levels.INFO)
                  else
                    vim.notify('❌ Commit failed: ' .. result, vim.log.levels.ERROR)
                  end
                elseif confirmation == 3 then
                  -- Edit - let user modify the message
                  local edited_msg = vim.fn.input('Edit commit message: ', commit_msg)
                  if edited_msg ~= '' then
                    local escaped_msg = vim.fn.shellescape(edited_msg)
                    local result = vim.fn.system('git commit -m ' .. escaped_msg)
                    if vim.v.shell_error == 0 then
                      vim.notify('✅ Committed: ' .. edited_msg, vim.log.levels.INFO)
                    else
                      vim.notify('❌ Commit failed: ' .. result, vim.log.levels.ERROR)
                    end
                  end
                elseif confirmation == 4 then
                  -- Show diff - open in new buffer
                  vim.cmd 'vnew'
                  local diff_lines = vim.split(staged_diff, '\n')
                  vim.api.nvim_buf_set_lines(0, 0, -1, false, diff_lines)
                  vim.bo.filetype = 'diff'
                  vim.bo.readonly = true
                  vim.notify('Diff shown. Close this buffer and run :AICommit again', vim.log.levels.INFO)
                else
                  -- No - cancel
                  vim.notify('Commit cancelled', vim.log.levels.INFO)
                end
              end)
            else
              vim.notify('Invalid commit message generated. Check chat for details.', vim.log.levels.WARN)
            end
          end,
        })
      end

      -- Quick problem solver
      function ai.quick_help()
        local line = vim.api.nvim_buf_get_lines(0, vim.fn.line '.' - 1, vim.fn.line '.', false)[1] or ''
        local word = vim.fn.expand '<cword>'

        local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })
        local diag_msg = ''
        if #diagnostics > 0 then
          diag_msg = '\nDiagnostic: ' .. diagnostics[1].message
        end

        local context = string.format('Help with line %d: %s\nWord: %s%s', vim.fn.line '.', line, word, diag_msg)

        require('CopilotChat').ask('Quick help: ' .. context, {
          selection = ai.smart_selection(),
        })
      end

      -- File analysis
      function ai.analyze_file()
        local ft = vim.bo.filetype
        local analysis_prompts = {
          go = 'Analyze this Go code for: errors, performance, concurrency issues, and best practices.',
          python = 'Analyze this Python code for: bugs, performance, type hints, and Pythonic patterns.',
          javascript = 'Analyze this JS code for: bugs, performance, async issues, and modern patterns.',
          typescript = 'Analyze this TS code for: type safety, bugs, performance, and best practices.',
          lua = 'Analyze this Lua code for: bugs, performance, and Neovim best practices.',
          default = 'Analyze this code for: bugs, performance, and best practices.',
        }

        local prompt = analysis_prompts[ft] or analysis_prompts.default
        require('CopilotChat').ask(prompt, {
          selection = require('CopilotChat.select').buffer,
        })
      end

      -- Quick prompt system
      function ai.quick_prompt()
        local prompts = {
          { key = 'f', name = 'Fix', prompt = '/COPILOT_FIX' },
          { key = 'e', name = 'Explain', prompt = '/COPILOT_EXPLAIN' },
          { key = 'r', name = 'Review', prompt = '/COPILOT_REVIEW' },
          { key = 'o', name = 'Optimize', prompt = '/COPILOT_OPTIMIZE' },
          { key = 't', name = 'Tests', prompt = '/COPILOT_TESTS' },
          { key = 'd', name = 'Docs', prompt = '/COPILOT_DOCS' },
          { key = 's', name = 'Security', prompt = 'Review for security vulnerabilities and suggest fixes.' },
          { key = 'c', name = 'Clean', prompt = 'Refactor this code for better readability and maintainability.' },
        }

        local prompt_text = table.concat(
          vim.tbl_map(function(p)
            return p.key .. '=' .. p.name
          end, prompts),
          ' | '
        )

        local choice = vim.fn.input('AI (' .. prompt_text .. '): ')
        if choice == '' then
          return
        end

        -- Find matching prompt
        for _, prompt in ipairs(prompts) do
          if choice:lower() == prompt.key then
            require('CopilotChat').ask(prompt.prompt, { selection = ai.smart_selection() })
            return
          end
        end

        -- If no match, treat as custom prompt
        require('CopilotChat').ask(choice, { selection = ai.smart_selection() })
      end

      -- ============================================================================
      -- KEYMAPS - Optimized for speed and workflow
      -- ============================================================================

      local keymap = vim.keymap.set

      -- INSTANT ACCESS (most used)
      keymap({ 'n', 'v' }, '<leader>af', ai.instant_fix, { desc = '[A]I [F]ix' })
      keymap({ 'n', 'v' }, '<leader>ae', ai.instant_explain, { desc = '[A]I [E]xplain' })
      keymap({ 'n', 'v' }, '<leader>ao', ai.instant_optimize, { desc = '[A]I [O]ptimize' })

      -- QUICK ACCESS
      keymap({ 'n', 'v' }, '<leader>a', ai.quick_prompt, { desc = '[A]I Quick Prompt' })
      keymap('n', '<leader>aa', '<cmd>CopilotChatToggle<CR>', { desc = '[A]I Toggle' })
      keymap('n', '<leader>ah', ai.quick_help, { desc = '[A]I [H]elp' })
      keymap('n', '<leader>ab', ai.analyze_file, { desc = '[A]I Analyze [B]uffer' })

      -- WORKFLOW ACTIONS
      keymap({ 'n', 'v' }, '<leader>at', ai.generate_tests, { desc = '[A]I [T]ests' })
      keymap({ 'n', 'v' }, '<leader>ad', ai.add_docs, { desc = '[A]I [D]ocs' })

      -- GIT WORKFLOW
      keymap('n', '<leader>ag', ai.smart_commit, { desc = '[A]I [G]it smart commit' })

      -- EMERGENCY KEYS
      keymap('n', '<F1>', ai.quick_help, { desc = 'AI Quick Help' })
      keymap({ 'n', 'v' }, '<F2>', ai.instant_fix, { desc = 'AI Fix' })

      -- CHAT CONTROLS
      keymap('n', '<leader>ar', '<cmd>CopilotChatReset<CR>', { desc = '[A]I [R]eset' })

      -- ============================================================================
      -- USER COMMANDS
      -- ============================================================================

      vim.api.nvim_create_user_command('AIFix', ai.instant_fix, { desc = 'AI fix current issue' })
      vim.api.nvim_create_user_command('AICommit', ai.smart_commit, { desc = 'AI smart commit with approval' })
      vim.api.nvim_create_user_command('AITests', ai.generate_tests, { desc = 'AI generate tests' })
      vim.api.nvim_create_user_command('AIDocs', ai.add_docs, { desc = 'AI add documentation' })
      vim.api.nvim_create_user_command('AIAnalyze', ai.analyze_file, { desc = 'AI analyze current file' })

      vim.api.nvim_create_user_command('AI', function(args)
        require('CopilotChat').ask(args.args, { selection = ai.smart_selection() })
      end, { nargs = '+', desc = 'Ask AI with smart context' })

      -- ============================================================================
      -- WORKFLOW HINTS
      -- ============================================================================

      -- Show helpful tips on first use
      vim.api.nvim_create_autocmd('User', {
        pattern = 'CopilotChatOpen',
        callback = function()
          vim.defer_fn(function()
            vim.notify(
              [[
AI Workflow Tips:
• <C-y> in chat = Apply changes
• gy in chat = Yank suggestion  
• gd in chat = Preview diff
• <leader>af = Auto-fix
• <leader>ag = Smart commit]],
              vim.log.levels.INFO
            )
          end, 2000)
        end,
      })
    end,
    cmd = {
      'CopilotChat',
      'AIFix',
      'AICommit',
      'AITests',
      'AIDocs',
      'AIAnalyze',
      'AI',
    },
    keys = {
      { '<leader>a', desc = '+AI Workflow', mode = { 'n', 'v' } },
      { '<F1>', desc = 'AI Help' },
      { '<F2>', desc = 'AI Fix' },
    },
  },
}
