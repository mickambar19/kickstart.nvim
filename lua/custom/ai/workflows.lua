local M = {}

local core = require 'custom.ai.core'
local prompts = require 'custom.ai.prompts'
local models = require 'custom.ai.models'

-- Smart context-aware menu
function M.smart_menu()
  local context = core.get_context()
  local items = {}

  -- Always available options
  table.insert(items, { label = 'Fix issues', value = 'fix' })
  table.insert(items, { label = 'Explain code', value = 'explain' })
  table.insert(items, { label = 'Review code', value = 'review' })
  table.insert(items, { label = 'Optimize performance', value = 'optimize' })

  -- Context-specific options
  if context.has_diagnostics then
    table.insert(items, 1, { label = 'Fix diagnostics ⚠️', value = 'fix_diagnostics' })
  end

  if context.is_test then
    table.insert(items, { label = 'Improve test', value = 'improve_test' })
    table.insert(items, { label = 'Add test cases', value = 'add_tests' })
  else
    table.insert(items, { label = 'Generate tests', value = 'tests' })
  end

  if context.framework == 'react' or context.framework == 'nextjs' then
    table.insert(items, { label = 'Add TypeScript types', value = 'types' })
    table.insert(items, { label = 'Convert to custom hook', value = 'extract_hook' })
    table.insert(items, { label = 'Optimize re-renders', value = 'optimize_react' })
  end

  if context.framework == 'nextjs' then
    table.insert(items, { label = 'Convert to Server Component', value = 'server_component' })
    table.insert(items, { label = 'Add loading/error states', value = 'loading_states' })
  end

  if context.in_function then
    table.insert(items, { label = 'Add JSDoc', value = 'jsdoc' })
    table.insert(items, { label = 'Extract function', value = 'extract' })
  end

  -- Model switch option
  table.insert(items, { label = '──────────────', value = 'separator' })
  table.insert(items, { label = 'Switch AI model', value = 'switch_model' })

  vim.ui.select(items, {
    prompt = 'AI Action:',
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice or choice.value == 'separator' then
      return
    end

    if choice.value == 'switch_model' then
      M.model_menu()
    elseif choice.value == 'fix_diagnostics' then
      core.ask('Fix all diagnostics in this file', {
        selection = require('CopilotChat.select').diagnostics,
      })
    elseif choice.value == 'optimize_react' then
      core.ask 'Optimize React re-renders: memoization, useCallback, useMemo'
    elseif choice.value == 'server_component' then
      core.ask 'Convert to Next.js Server Component if appropriate'
    elseif choice.value == 'loading_states' then
      core.ask 'Add proper loading and error states with Suspense boundaries'
    elseif choice.value == 'extract_hook' then
      core.ask 'Extract logic into a custom React hook with proper TypeScript types'
    elseif choice.value == 'jsdoc' then
      core.ask 'Add comprehensive JSDoc/TSDoc documentation'
    elseif choice.value == 'improve_test' then
      core.ask 'Improve this test: better assertions, edge cases, clarity'
    elseif choice.value == 'add_tests' then
      core.ask 'Add more test cases for better coverage'
    else
      core.quick_action(choice.value)
    end
  end)
end

-- Smart git commit with better UI
function M.smart_commit()
  local staged_diff = vim.fn.system 'git diff --cached'
  local has_staged = staged_diff ~= ''

  if not has_staged then
    -- Show files that can be staged
    local changed_files = vim.fn.system('git status --porcelain'):gsub('\n$', '')
    if changed_files == '' then
      vim.notify('No changes to commit', vim.log.levels.INFO)
      return
    end

    local confirm = vim.fn.confirm('No staged changes. Stage current file?', '&Yes\n&All changes\n&Cancel', 1)

    if confirm == 1 then
      vim.fn.system('git add ' .. vim.fn.shellescape(vim.fn.expand '%'))
    elseif confirm == 2 then
      vim.fn.system 'git add -A'
    else
      return
    end

    staged_diff = vim.fn.system 'git diff --cached'
  end

  -- Generate commit message
  core.ask('Generate a conventional commit message for these changes:\n\n' .. staged_diff, {
    callback = function(response)
      local msg = response:match '^[%s]*([^\n]+)' or response
      msg = msg:gsub('^["\']', ''):gsub('["\']$', '')

      vim.schedule(function()
        -- Show commit preview
        local lines = {
          'Commit message:',
          '',
          msg,
          '',
          'Files to commit:',
        }

        local files = vim.fn.system 'git diff --cached --name-status'
        for line in files:gmatch '[^\n]+' do
          table.insert(lines, '  ' .. line)
        end

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

        local win = vim.api.nvim_open_win(buf, true, {
          relative = 'editor',
          width = math.min(80, vim.o.columns - 4),
          height = math.min(#lines + 4, vim.o.lines - 4),
          col = (vim.o.columns - 80) / 2,
          row = (vim.o.lines - #lines - 4) / 2,
          style = 'minimal',
          border = 'rounded',
        })

        vim.keymap.set('n', '<CR>', function()
          vim.api.nvim_win_close(win, true)
          local result = vim.fn.system('git commit -m ' .. vim.fn.shellescape(msg))
          if vim.v.shell_error == 0 then
            vim.notify('✅ Committed successfully', vim.log.levels.INFO)
          else
            vim.notify('❌ Commit failed: ' .. result, vim.log.levels.ERROR)
          end
        end, { buffer = buf, desc = 'Confirm commit' })

        vim.keymap.set('n', 'q', function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, desc = 'Cancel commit' })

        vim.keymap.set('n', 'e', function()
          vim.api.nvim_win_close(win, true)
          local edited = vim.fn.input('Edit message: ', msg)
          if edited ~= '' then
            vim.fn.system('git commit -m ' .. vim.fn.shellescape(edited))
          end
        end, { buffer = buf, desc = 'Edit message' })

        -- Add help text
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
          '',
          "Press: <CR> to commit, 'q' to cancel, 'e' to edit",
        })
      end)
    end,
  })
end

-- Component creation workflow
function M.create_component()
  local name = vim.fn.input 'Component name: '
  if name == '' then
    return
  end

  local component_type = vim.fn.confirm('Component type:', '&Client Component\n&Server Component\n&Cancel', 1)

  if component_type == 3 then
    return
  end

  local is_server = component_type == 2
  local directive = is_server and '' or "'use client'\n\n"

  core.ask(string.format(
    [[Create a React component named %s with:
%s- TypeScript props interface
- Proper imports
- Basic structure with TODO for implementation
- Export statement]],
    name,
    directive
  ))
end

-- Hook creation workflow
function M.create_hook()
  local name = vim.fn.input 'Hook name (without "use"): '
  if name == '' then
    return
  end

  core.ask(string.format(
    [[Create a custom React hook named use%s with:
- TypeScript types for parameters and return value
- Proper imports
- Basic implementation with TODO comments
- Usage example in JSDoc]],
    name
  ))
end

-- Next.js page creation
function M.create_next_page()
  local route = vim.fn.input 'Route (e.g., blog/[slug]): '
  if route == '' then
    return
  end

  local page_type = vim.fn.confirm('Page type:', '&Static\n&Dynamic (SSR)\n&Client\n&Cancel', 1)

  if page_type == 4 then
    return
  end

  local template = ''
  if page_type == 1 then
    template = 'with generateStaticParams'
  elseif page_type == 2 then
    template = 'with dynamic rendering'
  else
    template = 'as client component'
  end

  core.ask(string.format(
    [[Create a Next.js page for route "%s" %s including:
- Proper TypeScript types
- Metadata export
- Loading and error boundaries
- Basic layout]],
    route,
    template
  ))
end

-- Model switching menu
function M.model_menu()
  local current = models.get_current_model()
  local items = {}

  for _, model in ipairs(models.models) do
    local label = model.display
    if model.name == current then
      label = label .. ' ✓'
    end
    if model.limit then
      local state = models.load_state()
      local usage = state.usage[model.name] or { count = 0 }
      label = label .. string.format(' (%d/%d)', usage.count, model.limit)
    end
    table.insert(items, { label = label, value = model.name, desc = model.description })
  end

  table.insert(items, { label = '──────────────', value = 'separator' })
  table.insert(items, { label = 'Show usage stats', value = 'usage' })

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
    else
      models.set_current_model(choice.value)
      vim.notify('Switched to ' .. choice.label, vim.log.levels.INFO)
    end
  end)
end

-- Contextual help based on current situation
function M.contextual_help()
  local context = core.get_context()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })

  if #diagnostics > 0 then
    -- Focus on the diagnostic
    core.ask(string.format('Explain this error and how to fix it:\n%s', diagnostics[1].message), { selection = require('CopilotChat.select').diagnostics })
  elseif context.in_function then
    -- Explain the function
    core.ask 'Explain what this function does and how to use it'
  else
    -- General help
    M.smart_menu()
  end
end

-- Test current function
function M.test_current_function()
  local node = vim.treesitter.get_node()
  if not node then
    vim.notify('No function found at cursor', vim.log.levels.WARN)
    return
  end

  -- Find function node
  while node and not vim.tbl_contains({ 'function_declaration', 'method_definition', 'arrow_function' }, node:type()) do
    node = node:parent()
  end

  if not node then
    vim.notify('No function found at cursor', vim.log.levels.WARN)
    return
  end

  core.ask('Generate comprehensive tests for this function including edge cases', {
    selection = function(source)
      local start_row, start_col, end_row, end_col = node:range()
      return source.bufnr, start_row, start_col, end_row, end_col
    end,
  })
end

-- Analyze file for all issues
function M.analyze_file()
  local context = core.get_context()

  -- Use Claude for complex analysis
  local prev_model = models.get_current_model()
  models.set_current_model(models.suggest_model 'complex')

  core.ask(
    [[Analyze this entire file for:
1. Bugs and potential issues
2. Performance problems
3. Security vulnerabilities
4. Code smells and tech debt
5. Missing error handling
6. Accessibility issues (if applicable)

Provide a prioritized list with specific line numbers and fixes.]],
    {
      selection = require('CopilotChat.select').buffer,
      callback = function()
        -- Restore previous model
        models.set_current_model(prev_model)
      end,
    }
  )
end

-- Quick explain error
function M.explain_error()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })
  if #diagnostics == 0 then
    vim.notify('No error at current line', vim.log.levels.INFO)
    return
  end

  core.ask(string.format('Explain this error and provide a fix:\n%s', diagnostics[1].message), { selection = require('CopilotChat.select').line })
end

return M
