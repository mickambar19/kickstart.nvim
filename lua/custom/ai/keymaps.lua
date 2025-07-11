local M = {}

function M.setup()
  local keymap = vim.keymap.set
  local core = require 'custom.ai.core'
  local workflows = require 'custom.ai.workflows'
  local models = require 'custom.ai.models'

  -- Smart quick menu (context-aware)
  keymap({ 'n', 'v' }, '<leader>a sm', workflows.smart_menu, { desc = '[A]I Smart Menu' })

  -- Instant actions
  keymap({ 'n', 'v' }, '<leader>af', function()
    core.quick_action 'fix'
  end, { desc = '[A]I [F]ix' })
  keymap({ 'n', 'v' }, '<leader>ae', function()
    core.quick_action 'explain'
  end, { desc = '[A]I [E]xplain' })
  keymap({ 'n', 'v' }, '<leader>ao', function()
    core.quick_action 'optimize'
  end, { desc = '[A]I [O]ptimize' })
  keymap({ 'n', 'v' }, '<leader>ar', function()
    core.quick_action 'review'
  end, { desc = '[A]I [R]eview' })

  -- Chat toggle
  keymap('n', '<leader>aa', '<cmd>CopilotChatToggle<CR>', { desc = '[A]I Toggle Ch[a]t' })

  -- Testing
  keymap({ 'n', 'v' }, '<leader>at', function()
    core.quick_action 'tests'
  end, { desc = '[A]I [T]ests' })
  keymap('n', '<leader>atf', workflows.test_current_function, { desc = '[A]I [T]est [F]unction' })
  -- keymap('n', '<leader>atc', workflows.test_component, { desc = '[A]I [T]est [C]omponent' })

  -- Documentation
  keymap({ 'n', 'v' }, '<leader>ad', function()
    core.quick_action 'docs'
  end, { desc = '[A]I [D]ocs' })
  -- keymap('n', '<leader>adc', workflows.document_component, { desc = '[A]I [D]oc [C]omponent' })

  -- TypeScript
  keymap({ 'n', 'v' }, '<leader>aty', function()
    core.quick_action 'types'
  end, { desc = '[A]I [Ty]pes' })
  keymap('n', '<leader>ati', workflows.add_interface, { desc = '[A]I [T]ype [I]nterface' })

  -- React/Next.js
  keymap('n', '<leader>arc', workflows.create_component, { desc = '[A]I [R]eact [C]omponent' })
  keymap('n', '<leader>arh', workflows.create_hook, { desc = '[A]I [R]eact [H]ook' })
  keymap('n', '<leader>anp', workflows.create_next_page, { desc = '[A]I [N]ext [P]age' })
  keymap('n', '<leader>ana', workflows.create_next_api, { desc = '[A]I [N]ext [A]PI' })

  keymap('n', '<leader>ag', workflows.smart_commit, { desc = '[A]I [G]it commit' })
  keymap('n', '<leader>agr', workflows.review_diff, { desc = '[A]I [G]it [R]eview diff' })

  keymap('n', '<leader>am', workflows.model_menu, { desc = '[A]I [M]odel menu' })
  keymap('n', '<leader>amu', models.show_usage_stats, { desc = '[A]I [M]odel [U]sage' })

  -- Quick model switches
  keymap('n', '<leader>amd', function()
    models.set_current_model 'gpt-4.1'
    vim.notify('Switched to GPT-4.1 (Daily)', vim.log.levels.INFO)
  end, { desc = '[A]I Model [D]aily (GPT-4.1)' })

  keymap('n', '<leader>amc', function()
    models.set_current_model 'claude-3-sonnet'
    vim.notify('Switched to Claude 3 Sonnet (Complex)', vim.log.levels.INFO)
  end, { desc = '[A]I Model [C]omplex (Claude)' })

  keymap('n', '<leader>asa', workflows.analyze_file, { desc = '[A]I [S]can [A]ll issues' })
  keymap('n', '<leader>asp', workflows.analyze_performance, { desc = '[A]I [S]can [P]erformance' })
  keymap('n', '<leader>ass', workflows.analyze_security, { desc = '[A]I [S]can [S]ecurity' })
  keymap({ 'n', 'v' }, '<leader>arf', function()
    core.quick_action 'refactor'
  end, { desc = '[A]I [R]e[f]actor' })

  keymap('n', '<leader>ah', workflows.contextual_help, { desc = '[A]I [H]elp (contextual)' })
  keymap('n', '<leader>a?', workflows.explain_error, { desc = '[A]I Explain error' })

  -- Emergency keys
  keymap('n', '<F1>', workflows.contextual_help, { desc = 'AI Quick Help' })
  keymap({ 'n', 'v' }, '<F2>', function()
    core.quick_action 'fix'
  end, { desc = 'AI Quick Fix' })

  keymap('n', '<leader>apr', '<cmd>CopilotChatReset<CR>', { desc = '[A]I [P]rompt [R]eset' })
  keymap('n', '<leader>aph', workflows.show_prompt_history, { desc = '[A]I [P]rompt [H]istory' })
end

return M
