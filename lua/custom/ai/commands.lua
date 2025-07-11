local M = {}

function M.setup()
  local core = require 'custom.ai.core'
  local workflows = require 'custom.ai.workflows'
  local models = require 'custom.ai.models'
  local prompts = require 'custom.ai.prompts'

  -- Basic AI command
  vim.api.nvim_create_user_command('AI', function(args)
    core.ask(args.args, { selection = core.smart_selection() })
  end, {
    nargs = '+',
    desc = 'Ask AI with smart context detection',
    complete = function(arg_lead)
      -- Provide completion for common prompts
      local completions = {
        'fix this',
        'explain this',
        'optimize for performance',
        'add types',
        'add tests',
        'refactor this',
        'review for bugs',
        'make this accessible',
      }
      return vim.tbl_filter(function(item)
        return item:match('^' .. arg_lead)
      end, completions)
    end,
  })

  -- Quick actions
  vim.api.nvim_create_user_command('AIFix', function()
    core.quick_action 'fix'
  end, { desc = 'AI fix issues' })

  vim.api.nvim_create_user_command('AIExplain', function()
    core.quick_action 'explain'
  end, { desc = 'AI explain code' })

  vim.api.nvim_create_user_command('AITest', function()
    core.quick_action 'tests'
  end, { desc = 'AI generate tests' })

  vim.api.nvim_create_user_command('AIDocs', function()
    core.quick_action 'docs'
  end, { desc = 'AI add documentation' })

  vim.api.nvim_create_user_command('AIReview', function()
    core.quick_action 'review'
  end, { desc = 'AI review code' })

  -- Git commands
  vim.api.nvim_create_user_command('AICommit', workflows.smart_commit, {
    desc = 'AI generate commit message',
  })

  vim.api.nvim_create_user_command('AIDiff', function()
    local diff = vim.fn.system 'git diff'
    if diff == '' then
      diff = vim.fn.system 'git diff --cached'
    end
    if diff ~= '' then
      core.ask('Review these changes and suggest improvements:\n\n' .. diff)
    else
      vim.notify('No changes to review', vim.log.levels.WARN)
    end
  end, { desc = 'AI review git diff' })

  -- Model management
  vim.api.nvim_create_user_command('AIModel', workflows.model_menu, {
    desc = 'AI model selection menu',
  })

  vim.api.nvim_create_user_command('AIUsage', function()
    models.show_usage_stats()
  end, { desc = 'Show AI model usage statistics' })

  -- Framework-specific commands
  vim.api.nvim_create_user_command('AIComponent', workflows.create_component, {
    desc = 'Create React component',
  })

  vim.api.nvim_create_user_command('AIHook', workflows.create_hook, {
    desc = 'Create React hook',
  })

  vim.api.nvim_create_user_command('AINextPage', workflows.create_next_page, {
    desc = 'Create Next.js page',
  })

  -- Analysis commands
  vim.api.nvim_create_user_command('AIAnalyze', workflows.analyze_file, {
    desc = 'Comprehensive file analysis',
  })

  vim.api.nvim_create_user_command('AIPerformance', function()
    core.ask [[Analyze this code for performance issues:
- Unnecessary re-renders (React)
- Memory leaks
- Inefficient algorithms
- Bundle size impact
Provide specific optimizations with examples.]]
  end, { desc = 'AI performance analysis' })

  vim.api.nvim_create_user_command('AISecurity', function()
    core.ask [[Analyze for security vulnerabilities:
- XSS vulnerabilities
- SQL injection risks
- Authentication/authorization issues
- Sensitive data exposure
- OWASP Top 10
Provide specific fixes for each issue found.]]
  end, { desc = 'AI security analysis' })

  -- Quick prompt command with completion
  vim.api.nvim_create_user_command('AIQuick', function(opts)
    local prompt_key = opts.args
    local quick = prompts.quick_prompts[prompt_key]

    if quick then
      core.ask(quick)
    else
      vim.notify('Unknown quick prompt: ' .. prompt_key, vim.log.levels.ERROR)
      vim.notify('Available: ' .. table.concat(vim.tbl_keys(prompts.quick_prompts), ', '), vim.log.levels.INFO)
    end
  end, {
    nargs = 1,
    desc = 'Execute quick prompt',
    complete = function()
      return vim.tbl_keys(prompts.quick_prompts)
    end,
  })

  -- Advanced debugging command
  vim.api.nvim_create_user_command('AIDebug', function()
    local context = core.get_context()
    local info = {
      '=== AI Debug Info ===',
      'Model: ' .. models.get_usage_info(),
      'File: ' .. context.filename,
      'Type: ' .. context.filetype,
      'Framework: ' .. (context.framework or 'none'),
      'Is Test: ' .. tostring(context.is_test),
      'In Function: ' .. tostring(context.in_function),
      'Has Diagnostics: ' .. tostring(context.has_diagnostics),
      '',
      'Available quick prompts:',
    }

    for key, _ in pairs(prompts.quick_prompts) do
      table.insert(info, '  ' .. key)
    end

    vim.notify(table.concat(info, '\n'), vim.log.levels.INFO)
  end, { desc = 'Show AI debug information' })
end

return M
