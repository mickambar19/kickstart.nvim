local M = {}

-- Smart context-aware menu with enhanced options
function M.smart_menu()
  local core = require 'custom.ai-ultra.core'
  local context = core.get_context()
  local items = {}

  -- Always available core actions with icons
  table.insert(items, { label = '🔍 Explain code', value = 'explain', key = 'e' })
  table.insert(items, { label = '🐛 Fix issues', value = 'fix', key = 'f' })
  table.insert(items, { label = '🔬 Review code', value = 'review', key = 'r' })
  table.insert(items, { label = '⚡ Optimize performance', value = 'optimize', key = 'o' })
  table.insert(items, { label = '📚 Add documentation', value = 'docs', key = 'd' })

  -- Context-specific options (high priority)
  if context.has_diagnostics then
    table.insert(items, 1, {
      label = '🚨 Fix diagnostics (' .. context.diagnostic_count .. ' issues)',
      value = 'fix_diagnostics',
      key = '!',
    })
  end

  if context.is_test then
    table.insert(items, { label = '📈 Improve test coverage', value = 'improve_test', key = 'i' })
    table.insert(items, { label = '🧪 Add test cases', value = 'add_tests', key = 't' })
  else
    table.insert(items, { label = '🧪 Generate tests', value = 'tests', key = 't' })
  end

  -- Separator
  table.insert(items, { label = '────────────────────────', value = 'separator1', key = '' })

  -- Framework-specific options
  if context.framework == 'react' or context.framework == 'nextjs' then
    table.insert(items, { label = '🎯 Add TypeScript types', value = 'types', key = 'y' })
    table.insert(items, { label = '🎣 Convert to custom hook', value = 'extract_hook', key = 'h' })
    table.insert(items, { label = '🔄 Optimize re-renders', value = 'optimize_react', key = 'm' })

    if context.framework == 'nextjs' then
      table.insert(items, { label = '🖥️ Convert to Server Component', value = 'server_component', key = 's' })
      table.insert(items, { label = '📱 Add responsive design', value = 'responsive', key = 'p' })
    end
  elseif context.framework == 'vue' then
    table.insert(items, { label = '⚛️ Optimize Vue composition', value = 'vue_optimize', key = 'v' })
  elseif context.framework == 'django' or context.framework == 'flask' then
    table.insert(items, { label = '🐍 Optimize Python patterns', value = 'python_optimize', key = 'p' })
    table.insert(items, { label = '🔐 Add security checks', value = 'python_security', key = 's' })
  elseif context.framework == 'gin' or context.framework == 'echo' then
    table.insert(items, { label = '🐹 Add Go error handling', value = 'go_errors', key = 'g' })
    table.insert(items, { label = '⚡ Optimize goroutines', value = 'go_concurrency', key = 'c' })
  end

  -- Language-specific options
  if context.filetype == 'python' then
    table.insert(items, { label = '🐍 Add type hints', value = 'python_types', key = 'n' })
    table.insert(items, { label = '📊 Add docstrings', value = 'python_docs', key = 'x' })
  elseif context.filetype == 'go' then
    table.insert(items, { label = '📝 Add Go documentation', value = 'go_docs', key = 'w' })
    table.insert(items, { label = '🧪 Convert to table tests', value = 'go_table_tests', key = 'b' })
  elseif context.filetype == 'javascript' or context.filetype == 'typescript' then
    table.insert(items, { label = '🔄 Convert to async/await', value = 'async_await', key = 'a' })
    table.insert(items, { label = '📦 Optimize bundle size', value = 'bundle_optimize', key = 'z' })
  end

  -- File-specific options
  if context.in_function and context.function_name then
    table.insert(items, {
      label = '🔧 Refactor function: ' .. context.function_name,
      value = 'refactor_function',
      key = 'u',
    })
  end

  if context.is_config then
    table.insert(items, { label = '⚙️ Validate configuration', value = 'validate_config', key = 'l' })
  end

  -- Separator
  table.insert(items, { label = '────────────────────────', value = 'separator2', key = '' })

  -- Advanced options
  table.insert(items, { label = '🛡️ Security audit', value = 'security_audit', key = 'S' })
  table.insert(items, { label = '♿ Accessibility check', value = 'a11y_check', key = 'A' })
  table.insert(items, { label = '📊 Performance analysis', value = 'perf_analysis', key = 'P' })
  table.insert(items, { label = '🔄 Refactor for maintainability', value = 'refactor', key = 'R' })

  -- Separator
  table.insert(items, { label = '────────────────────────', value = 'separator3', key = '' })

  -- Meta options
  table.insert(items, { label = '🤖 Switch AI model', value = 'switch_model', key = 'M' })
  table.insert(items, { label = '❓ Custom question', value = 'custom_question', key = '?' })

  vim.ui.select(items, {
    prompt = string.format('🤖 AI Ultra (%s) - Choose action [key]:', context.framework or context.filetype),
    format_item = function(item)
      if item.value:match 'separator' then
        return item.label
      end
      local key_hint = item.key ~= '' and (' [' .. item.key .. ']') or ''
      return item.label .. key_hint
    end,
  }, function(choice)
    if not choice or choice.value:match 'separator' then
      return
    end

    M.execute_menu_action(choice.value, context)
  end)
end

-- Execute menu actions with context awareness
function M.execute_menu_action(action, context)
  local core = require 'custom.ai-ultra.core'

  if action == 'switch_model' then
    M.model_menu()
  elseif action == 'custom_question' then
    local prompt = vim.fn.input 'Ask AI: '
    if prompt ~= '' then
      core.ask(prompt, { selection = core.smart_selection() })
    end
  elseif action == 'fix_diagnostics' then
    core.ask('Fix all diagnostic issues in this code', {
      selection = require('CopilotChat.select').diagnostics,
    })
  elseif action == 'optimize_react' then
    core.ask [[Optimize this React code for performance:
- Use React.memo where appropriate
- Implement useCallback for event handlers
- Add useMemo for expensive calculations
- Prevent unnecessary re-renders
- Consider code splitting if applicable]]
  elseif action == 'server_component' then
    core.ask [[Convert this to a Next.js Server Component if appropriate:
- Move to server-side rendering
- Remove client-side state if possible
- Use server actions for data mutations
- Maintain proper error boundaries]]
  elseif action == 'responsive' then
    core.ask [[Add responsive design to this component:
- Mobile-first approach
- Tailwind responsive utilities
- Proper breakpoints
- Touch-friendly interactions
- Accessibility considerations]]
  elseif action == 'extract_hook' then
    core.ask [[Extract reusable logic into a custom React hook:
- Identify stateful logic
- Create proper hook interface
- Add TypeScript types
- Include usage examples
- Follow hook naming conventions]]
  elseif action == 'python_types' then
    core.ask [[Add comprehensive Python type hints:
- Function parameters and return types
- Variable annotations where helpful
- Generic types for collections
- Union types for flexible parameters
- Import necessary typing modules]]
  elseif action == 'python_docs' then
    core.ask [[Add comprehensive Python docstrings:
- Google or NumPy style format
- Parameter descriptions
- Return value documentation
- Example usage
- Raised exceptions]]
  elseif action == 'go_errors' then
    core.ask [[Add proper Go error handling:
- Check and handle all errors
- Use meaningful error messages
- Wrap errors with context
- Consider custom error types
- Follow Go error conventions]]
  elseif action == 'go_docs' then
    core.ask [[Add Go documentation comments:
- Package-level documentation
- Function and type comments
- Follow Go doc conventions
- Include usage examples
- Document exported identifiers]]
  elseif action == 'async_await' then
    core.ask [[Convert Promise-based code to async/await:
- Replace .then() chains
- Add proper error handling with try/catch
- Maintain parallel execution where appropriate
- Use Promise.all() for concurrent operations]]
  elseif action == 'security_audit' then
    core.ask [[Perform comprehensive security audit:
- Input validation and sanitization
- SQL injection prevention
- XSS vulnerabilities
- Authentication/authorization flaws
- Sensitive data exposure
- Follow OWASP Top 10 guidelines]]
  elseif action == 'a11y_check' then
    core.ask [[Audit for accessibility (a11y) compliance:
- WCAG 2.1 AA compliance
- Screen reader compatibility
- Keyboard navigation support
- Color contrast validation
- ARIA labels and roles
- Focus management]]
  elseif action == 'perf_analysis' then
    core.ask [[Analyze performance characteristics:
- Time and space complexity
- Bottleneck identification
- Memory usage optimization
- Database query efficiency
- Rendering performance (if applicable)
- Caching opportunities]]
  elseif action == 'validate_config' then
    core.ask [[Validate and improve this configuration:
- Check for syntax errors
- Verify required fields
- Suggest security improvements
- Add helpful comments
- Follow best practices for this config type]]
  elseif action == 'refactor_function' then
    core.ask(string.format(
      [[Refactor the function '%s' for better design:
- Single Responsibility Principle
- Reduce complexity and nesting
- Improve readability
- Extract helper functions if needed
- Add proper error handling]],
      context.function_name or 'current function'
    ))
  else
    -- Default to core quick actions
    core.quick_action(action)
  end
end

-- Enhanced commit message generation with conventional commits
function M.smart_commit()
  local core = require 'custom.ai-ultra.core'

  -- Check for staged changes
  local staged_diff = vim.fn.system 'git diff --cached'
  local has_staged = staged_diff ~= ''

  if not has_staged then
    -- Show available files to stage
    local changed_files = vim.fn.system('git status --porcelain'):gsub('\n$', '')
    if changed_files == '' then
      vim.notify('No changes to commit', vim.log.levels.INFO)
      return
    end

    local options = {
      'Stage current file and commit',
      'Stage all changes and commit',
      'Show changed files',
      'Cancel',
    }

    vim.ui.select(options, {
      prompt = 'No staged changes found:',
    }, function(choice)
      if choice == options[1] then
        vim.fn.system('git add ' .. vim.fn.shellescape(vim.fn.expand '%'))
      elseif choice == options[2] then
        vim.fn.system 'git add -A'
      elseif choice == options[3] then
        vim.notify('Changed files:\n' .. changed_files, vim.log.levels.INFO)
        return
      else
        return
      end

      -- Recursively call after staging
      M.smart_commit()
    end)
    return
  end

  -- Get enhanced context for commit message
  local context = core.get_context()
  local file_count = #vim.split(vim.fn.system 'git diff --cached --name-only', '\n', { trimempty = true })

  staged_diff = vim.fn.system 'git diff --cached'

  -- Generate enhanced commit message
  core.ask(
    string.format(
      [[Generate a conventional commit message for these changes.

Context:
- Files changed: %d
- Project type: %s
- Framework: %s

Requirements:
- Use conventional commit format: type(scope): description
- Types: feat, fix, docs, style, refactor, test, chore, perf, ci
- Keep description under 50 characters
- Add body with bullet points if needed for complex changes
- Consider breaking changes

Respond with ONLY the commit message, no explanations.

Changes:
%s]],
      file_count,
      context.filetype,
      context.framework or 'none',
      staged_diff
    ),
    {
      callback = function(response)
        if not response or response == '' then
          vim.notify('Failed to generate commit message', vim.log.levels.ERROR)
          return
        end

        local msg = M.extract_commit_message(response)
        if msg then
          vim.schedule(function()
            M.show_commit_preview(msg, staged_diff)
          end)
        end
      end,
    }
  )
end

-- Enhanced commit message extraction with better patterns
function M.extract_commit_message(response)
  if not response or response == '' then
    return nil
  end

  local clean_response = response:gsub('^%s+', ''):gsub('%s+$', '')

  -- Enhanced patterns for commit message extraction
  local patterns = {
    -- Direct conventional commit format
    '^([a-z]+%([^)]*%): .+)$',
    '^([a-z]+: .+)$',
    -- Quoted commit messages
    '"([^"]+)"',
    "'([^']+)'",
    '`([^`]+)`',
    -- Code block extraction
    '```[^\n]*\n([^\n]+)\n```',
    -- First meaningful line
    '^([^\n]+)$',
  }

  local lines = {}
  for line in clean_response:gmatch '[^\r\n]+' do
    local trimmed = line:gsub('^%s+', ''):gsub('%s+$', '')
    if trimmed ~= '' and not trimmed:match '^[Hh]ere' and not trimmed:match '^[Bb]ased on' then
      table.insert(lines, trimmed)
    end
  end

  -- Try patterns on each line
  for _, line in ipairs(lines) do
    for _, pattern in ipairs(patterns) do
      local match = line:match(pattern)
      if match and #match > 10 and #match < 120 then
        return match:gsub('^["\']', ''):gsub('["\']$', '')
      end
    end
  end

  -- Fallback: use first reasonable line
  for _, line in ipairs(lines) do
    if #line > 10 and #line < 100 then
      return line
    end
  end

  return nil
end

-- Enhanced commit preview with better UI
function M.show_commit_preview(msg, diff)
  local lines = {
    '📝 Commit Preview',
    string.rep('═', 60),
    '',
    '💬 Commit Message:',
    '  ' .. msg,
    '',
    '📊 Changes Summary:',
  }

  -- Add file statistics
  local stats = vim.fn.system('git diff --cached --shortstat'):gsub('\n$', '')
  if stats ~= '' then
    table.insert(lines, '  ' .. stats)
  end

  table.insert(lines, '')
  table.insert(lines, '📁 Files to commit:')

  local files = vim.fn.system 'git diff --cached --name-status'
  if files ~= '' then
    for line in files:gmatch '[^\n]+' do
      local status = line:match '^(%a)'
      local file = line:match '^%a%s+(.+)'
      local icon = status == 'M' and '📝' or status == 'A' and '➕' or status == 'D' and '🗑️' or '📄'
      table.insert(lines, string.format('  %s %s', icon, file))
    end
  end

  table.insert(lines, '')
  table.insert(lines, '⌨️  Actions:')
  table.insert(lines, '  <Enter> - Commit with this message')
  table.insert(lines, '  e       - Edit message')
  table.insert(lines, '  d       - Show full diff')
  table.insert(lines, '  q       - Cancel')

  -- Create enhanced popup
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'gitcommit')

  local width = math.max(60, math.min(100, vim.o.columns - 10))
  local height = math.min(#lines + 4, vim.o.lines - 6)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Git Commit Preview ',
    title_pos = 'center',
  })

  -- Enhanced keymaps
  local function close_and_commit(commit_msg)
    vim.api.nvim_win_close(win, true)
    local result = vim.fn.system('git commit -m ' .. vim.fn.shellescape(commit_msg))
    if vim.v.shell_error == 0 then
      vim.notify('✅ Committed successfully!', vim.log.levels.INFO)
    else
      vim.notify('❌ Commit failed: ' .. result, vim.log.levels.ERROR)
    end
  end

  vim.keymap.set('n', '<CR>', function()
    close_and_commit(msg)
  end, { buffer = buf })

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })

  vim.keymap.set('n', 'e', function()
    vim.api.nvim_win_close(win, true)

    local edited_msg = vim.fn.input('Edit commit message: ', msg)
    if edited_msg ~= '' then
      close_and_commit(edited_msg)
    end
  end, { buffer = buf })

  vim.keymap.set('n', 'd', function()
    vim.api.nvim_win_close(win, true)

    -- Show full diff in new buffer
    local diff_buf = vim.api.nvim_create_buf(false, true)
    local diff_lines = vim.split(diff, '\n')
    vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, diff_lines)
    vim.api.nvim_buf_set_option(diff_buf, 'filetype', 'diff')
    vim.api.nvim_buf_set_option(diff_buf, 'modifiable', false)

    vim.cmd 'split'
    vim.api.nvim_win_set_buf(0, diff_buf)
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = diff_buf })
  end, { buffer = buf })
end

-- Enhanced model switching menu
function M.model_menu()
  local ok_models, models = pcall(require, 'custom.ai-ultra.models')
  if not ok_models then
    vim.notify('Model management not available', vim.log.levels.WARN)
    return
  end

  local current = models.get_current_model()
  local items = {}

  for _, model in ipairs(models.models) do
    local label = model.display
    local status_icon = '⚪'
    local status_info = ''

    if model.name == current then
      status_icon = '🟢'
      label = label .. ' (Current)'
    end

    if model.limit then
      local state = models.load_state()
      local usage = state.usage[model.name] or { count = 0 }
      local percentage = math.floor(usage.count / model.limit * 100)
      status_info = string.format(' [%d/%d - %d%%]', usage.count, model.limit, percentage)

      if percentage >= 90 then
        status_icon = '🔴'
      elseif percentage >= 70 then
        status_icon = '🟡'
      end
    else
      status_info = ' [Unlimited]'
    end

    table.insert(items, {
      label = status_icon .. ' ' .. label .. status_info,
      value = model.name,
      description = model.description,
      model = model,
    })
  end

  table.insert(items, { label = '────────────────────────', value = 'separator' })
  table.insert(items, { label = '📊 Show usage statistics', value = 'usage' })
  table.insert(items, { label = '⚙️ Model preferences', value = 'preferences' })

  vim.ui.select(items, {
    prompt = 'Select AI Model:',
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice or choice.value == 'separator' then
      return
    end

    if choice.value == 'usage' then
      models.show_usage_stats()
    elseif choice.value == 'preferences' then
      M.show_model_preferences()
    else
      models.set_current_model(choice.value)
    end
  end)
end

-- Model preferences configuration
function M.show_model_preferences()
  local ok_models, models = pcall(require, 'custom.ai-ultra.models')
  if not ok_models then
    return
  end

  local state = models.load_state()
  local prefs = state.preferences

  local options = {
    string.format('Daily model: %s', prefs.preferred_daily),
    string.format('Complex model: %s', prefs.preferred_complex),
    string.format('Fast model: %s', prefs.preferred_fast),
    string.format('Auto-switch: %s', prefs.auto_switch and 'Enabled' or 'Disabled'),
    'Save and close',
  }

  vim.ui.select(options, {
    prompt = 'Model Preferences:',
  }, function(choice)
    if choice and choice:match 'Save' then
      models.save_state(state)
      vim.notify('Preferences saved', vim.log.levels.INFO)
    elseif choice then
      -- Handle preference changes
      vim.notify('Preference editing not implemented yet', vim.log.levels.INFO)
    end
  end)
end

-- Additional workflow functions for specific use cases
function M.contextual_help()
  local core = require 'custom.ai-ultra.core'
  local context = core.get_context()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })

  if #diagnostics > 0 then
    core.ask(string.format('Explain this error and provide a step-by-step fix:\n%s', diagnostics[1].message), {
      selection = require('CopilotChat.select').line,
    })
  elseif context.in_function then
    core.ask 'Explain what this function does, how to use it, and any potential improvements.'
  else
    M.smart_menu()
  end
end

function M.explain_error()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })
  if #diagnostics == 0 then
    vim.notify('No error at current line', vim.log.levels.INFO)
    return
  end

  local core = require 'custom.ai-ultra.core'
  core.ask(string.format('Explain this error and provide a comprehensive fix:\n%s', diagnostics[1].message), {
    selection = require('CopilotChat.select').line,
  })
end

function M.analyze_file()
  local core = require 'custom.ai-ultra.core'
  local context = core.get_context()

  -- Switch to complex model for analysis
  local ok_models, models = pcall(require, 'custom.ai-ultra.models')
  local prev_model = nil
  if ok_models then
    prev_model = models.get_current_model()
    models.set_current_model(models.suggest_model('analysis', 'complex'))
  end

  core.ask(
    string.format(
      [[Perform comprehensive analysis of this %s file:

1. **Code Quality Issues**
   - Bugs and potential runtime errors
   - Code smells and anti-patterns
   - Maintainability concerns

2. **Performance Analysis**
   - Algorithm efficiency
   - Memory usage patterns
   - Optimization opportunities

3. **Security Review**
   - Vulnerability assessment
   - Input validation gaps
   - Security best practices

4. **Architecture & Design**
   - Design pattern usage
   - SOLID principles adherence
   - Refactoring opportunities

5. **Framework-Specific** (%s)
   - Best practices compliance
   - Framework-specific optimizations
   - Modern pattern adoption

Provide actionable recommendations with specific line numbers and code examples.]],
      context.filetype,
      context.framework or 'none'
    ),
    {
      selection = require('CopilotChat.select').buffer,
      callback = function()
        -- Restore previous model
        if prev_model and ok_models then
          models.set_current_model(prev_model)
        end
      end,
    }
  )
end

function M.setup()
  vim.notify('AI Ultra Workflows: Ready', vim.log.levels.DEBUG)
end

return M
