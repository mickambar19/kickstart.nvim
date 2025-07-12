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

  -- Enhanced test generation with multi-part responses to prevent truncation
  vim.api.nvim_create_user_command('AITestComplete', function(args)
    local selection = core.smart_selection()

    require('CopilotChat').ask(
      [[First, provide the complete test file structure for this code:

1. File header with all imports
2. Test suite organization 
3. Setup and teardown blocks
4. List of all test cases to be implemented

Then, in your next response, I'll ask you to implement each test case group.

**IMPORTANT**: This is part 1 of a multi-part response. Provide complete structure.]],
      {
        selection = selection,
        callback = function(response)
          vim.schedule(function()
            vim.defer_fn(function()
              require('CopilotChat').ask [[Now implement ALL the test cases you outlined:

**PART 2**: Complete implementation of all test functions.

For each test:
- Full function implementation
- All assertions and setup
- Mock configurations
- Error handling

Complete ALL tests - do not truncate. If this response gets long, that's expected and desired.]]
            end, 2000)
          end)
        end,
      }
    )
  end, { desc = 'Generate complete test suite (multi-part)' })

  -- Chunked test generation for large test suites
  vim.api.nvim_create_user_command('AITestChunked', function(args)
    local selection = core.smart_selection()

    local chunks = {
      {
        title = 'Test Structure & Imports',
        prompt = [[Provide the complete test file setup:
1. All necessary imports (testing framework, mocks, module under test)
2. Test suite structure with describe blocks
3. Global setup and teardown
4. Mock configurations
5. Helper functions if needed

Make this response complete and self-contained.]],
      },
      {
        title = 'Happy Path Tests',
        prompt = [[Now implement all happy path test cases:
- Normal usage scenarios
- Expected inputs and outputs  
- Successful operations
- Valid data flows

Provide complete test functions with full implementations.]],
      },
      {
        title = 'Edge Cases & Error Tests',
        prompt = [[Implement edge cases and error handling tests:
- Boundary values (0, 1, -1, max/min)
- Empty/null/undefined inputs
- Invalid data types
- Exception scenarios
- Error boundaries

Complete all test implementations.]],
      },
    }

    local function execute_chunk(index)
      if index > #chunks then
        vim.notify('All test chunks completed!', vim.log.levels.INFO)
        return
      end

      local chunk = chunks[index]
      vim.notify(string.format('Generating %s (%d/%d)', chunk.title, index, #chunks), vim.log.levels.INFO)

      require('CopilotChat').ask(chunk.prompt, {
        selection = selection,
        callback = function(response)
          vim.schedule(function()
            vim.defer_fn(function()
              local continue = vim.fn.confirm(
                string.format('Generated %s. Continue to %s?', chunk.title, index < #chunks and chunks[index + 1].title or 'finish'),
                '&Yes\n&No\n&Regenerate current',
                1
              )

              if continue == 1 then
                execute_chunk(index + 1)
              elseif continue == 3 then
                execute_chunk(index)
              end
            end, 1000)
          end)
        end,
      })
    end

    execute_chunk(1)
  end, { desc = 'Generate tests in manageable chunks' })

  -- Anti-truncation commands
  vim.api.nvim_create_user_command('AIContinue', function(args)
    local prompt = args.args ~= '' and args.args
      or 'Continue your previous response from exactly where you left off. Complete any unfinished code blocks, functions, or explanations. Provide the remaining content.'
    require('CopilotChat').ask(prompt)
  end, {
    nargs = '*',
    desc = 'Continue truncated AI response',
  })

  vim.api.nvim_create_user_command('AIComplete', function(args)
    local section = args.args
    require('CopilotChat').ask(string.format(
      [[Your previous response appears to be incomplete. Please complete the %s section.

Provide the missing content including:
- Any unfinished code blocks
- Complete function implementations  
- Full explanations
- All remaining test cases

Continue from where you left off and finish completely.]],
      section
    ))
  end, {
    nargs = 1,
    complete = function(arg_lead)
      return { 'code block', 'test cases', 'function', 'explanation', 'imports', 'setup', 'mocks' }
    end,
    desc = 'Complete specific section of AI response',
  })

  vim.api.nvim_create_user_command('AICheckComplete', function()
    require('CopilotChat').ask [[Analyze your previous response for completeness:

1. Are there any unfinished code blocks (missing closing braces, incomplete functions)?
2. Did you finish all the test cases you mentioned?
3. Are there any cut-off explanations?
4. Is any promised content missing?

If incomplete, provide the missing content. If complete, confirm with "Response is complete."]]
  end, { desc = 'Check if AI response is complete' })

  -- Enhanced complete action commands
  local function create_complete_action(action_name, description)
    vim.api.nvim_create_user_command('AI' .. action_name, function()
      local context = core.get_context()
      local enhanced_prompt = prompts.get_enhanced_prompt(action_name:lower(), context)

      if enhanced_prompt then
        core.ask(enhanced_prompt.text, {
          selection = core.smart_selection(),
          system_prompt = enhanced_prompt.system,
        })
      else
        core.quick_action(action_name:lower())
      end
    end, { desc = description })
  end

  create_complete_action('TestComplete', 'Generate complete comprehensive tests')
  create_complete_action('ExplainComplete', 'Provide complete detailed explanation')
  create_complete_action('ReviewComplete', 'Complete comprehensive code review')
  create_complete_action('RefactorComplete', 'Complete refactoring with explanations')

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

  -- Response monitoring for truncation detection
  local function setup_response_monitoring()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'CopilotChatResponse',
      callback = function(event)
        local response = event.data and event.data.response or ''
        local is_truncated = false

        if response:match '```[^`]*$' then
          is_truncated = true
        elseif response:match '%.%.%.$' then
          is_truncated = true
        elseif #response > 1000 and not response:match '[.!?]%s*$' then
          is_truncated = true
        end

        if is_truncated then
          vim.schedule(function()
            vim.notify('⚠️  Response appears truncated. Use :AIContinue to get the rest.', vim.log.levels.WARN)
          end)
        end
      end,
    })
  end

  setup_response_monitoring()
end

return M
