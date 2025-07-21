-- lua/custom/ai-ultra/keymaps.lua
local M = {}

function M.setup()
  -- Safe module loading with function validation
  local core = require 'custom.ai-ultra.core'
  local ok_workflows, workflows = pcall(require, 'custom.ai-ultra.workflows')
  local ok_models, models = pcall(require, 'custom.ai-ultra.models')
  local ok_layout, layout = pcall(require, 'custom.ai-ultra.layout')

  -- Validate core functions exist
  if not core or type(core.quick_action) ~= 'function' then
    vim.notify('AI Ultra: Core module or quick_action function not available', vim.log.levels.ERROR)
    return
  end

  -- Helper function to safely set keymaps
  local function safe_keymap(mode, lhs, rhs, opts)
    if type(rhs) == 'function' or type(rhs) == 'string' then
      vim.keymap.set(mode, lhs, rhs, opts)
    else
      vim.notify(string.format('AI Ultra: Invalid keymap for %s - rhs is %s', lhs, type(rhs)), vim.log.levels.ERROR)
    end
  end

  local keymap = safe_keymap

  -- ============================================================================
  -- INSTANT ACTIONS (No conflicts, immediate execution)
  -- ============================================================================

  -- Core AI actions - single letter after <leader>a (INSTANT, no delays)
  keymap({ 'n', 'v' }, '<leader>ae', function()
    core.quick_action 'explain'
  end, { desc = '[A]I [E]xplain' })

  keymap({ 'n', 'v' }, '<leader>af', function()
    core.quick_action 'fix'
  end, { desc = '[A]I [F]ix' })

  keymap({ 'n', 'v' }, '<leader>ar', function()
    core.quick_action 'review'
  end, { desc = '[A]I [R]eview' })

  keymap({ 'n', 'v' }, '<leader>ao', function()
    core.quick_action 'optimize'
  end, { desc = '[A]I [O]ptimize' })

  keymap({ 'n', 'v' }, '<leader>ad', function()
    core.quick_action 'docs'
  end, { desc = '[A]I [D]ocs' })

  keymap({ 'n', 'v' }, '<leader>ax', function()
    core.quick_action 'refactor'
  end, { desc = '[A]I Refactor (e[X]tract)' })

  keymap({ 'n', 'v' }, '<leader>ay', function()
    core.quick_action 'types'
  end, { desc = '[A]I T[Y]pes' })

  -- Test generation - single action, no sub-menus
  keymap({ 'n', 'v' }, '<leader>at', function()
    core.quick_action 'tests'
  end, { desc = '[A]I [T]ests' })

  -- ============================================================================
  -- MENU SYSTEMS (Single entry points, no conflicts)
  -- ============================================================================

  -- Main AI menu - no conflicts
  keymap({ 'n', 'v' }, '<leader>ai', function()
    if ok_workflows and workflows and type(workflows.smart_menu) == 'function' then
      workflows.smart_menu()
    else
      vim.notify('Smart menu unavailable, using basic explain', vim.log.levels.WARN)
      core.quick_action 'explain'
    end
  end, { desc = '[A]I [I]nteractive menu' })

  -- Quick ask - no conflicts
  keymap({ 'n', 'v' }, '<leader>ak', function()
    local prompt = vim.fn.input 'Ask AI: '
    if prompt ~= '' then
      if type(core.ask) == 'function' and type(core.smart_selection) == 'function' then
        core.ask(prompt, { selection = core.smart_selection() })
      else
        vim.notify('AI ask function not available', vim.log.levels.ERROR)
      end
    end
  end, { desc = '[A]I As[K] custom prompt' })

  -- Chat controls - no conflicts
  --
  if ok_layout and layout then
    layout.setup_layout()
  end
  keymap('n', '<leader>az', '<cmd>CopilotChatReset<CR>', { desc = '[A]I [Z]ero/reset chat' })

  -- ============================================================================
  -- CATEGORY PREFIXES (Always lead to sub-actions, never conflicts)
  -- ============================================================================

  -- Git AI category - all <leader>ag* commands
  if ok_workflows and workflows then
    if type(workflows.smart_commit) == 'function' then
      keymap('n', '<leader>aga', workflows.smart_commit, { desc = '[A]I [G]it [A]uto commit' })
    end

    keymap('n', '<leader>agr', function()
      local diff = vim.fn.system 'git diff'
      if diff == '' then
        diff = vim.fn.system 'git diff --cached'
      end
      if diff ~= '' then
        if type(core.ask) == 'function' then
          core.ask('Review these changes and suggest improvements:\n\n' .. diff)
        end
      else
        vim.notify('No changes to review', vim.log.levels.WARN)
      end
    end, { desc = '[A]I [G]it [R]eview diff' })

    keymap('n', '<leader>agd', function()
      local diff = vim.fn.system 'git diff'
      if diff == '' then
        diff = vim.fn.system 'git diff --cached'
      end
      if diff ~= '' then
        if type(core.ask) == 'function' then
          core.ask('Analyze these git changes for potential bugs, breaking changes, and security issues:\n\n' .. diff)
        end
      else
        vim.notify('No changes to analyze', vim.log.levels.WARN)
      end
    end, { desc = '[A]I [G]it [D]iff analyze' })

    keymap('n', '<leader>agl', function()
      local log = vim.fn.system 'git log --oneline -10'
      if log ~= '' then
        if type(core.ask) == 'function' then
          core.ask('Analyze these recent commits and suggest improvements to commit practices:\n\n' .. log)
        end
      else
        vim.notify('No git history found', vim.log.levels.WARN)
      end
    end, { desc = '[A]I [G]it [L]og analyze' })
  end

  -- Model management category - all <leader>am* commands
  if ok_models and models then
    keymap('n', '<leader>ama', function()
      if ok_workflows and workflows and type(workflows.model_menu) == 'function' then
        workflows.model_menu()
      elseif type(models.show_usage_stats) == 'function' then
        models.show_usage_stats()
      else
        vim.notify('Model management unavailable', vim.log.levels.WARN)
      end
    end, { desc = '[A]I [M]odel [A]ll models' })

    if type(models.show_usage_stats) == 'function' then
      keymap('n', '<leader>amu', models.show_usage_stats, { desc = '[A]I [M]odel [U]sage' })
    end

    if type(models.set_current_model) == 'function' then
      keymap('n', '<leader>amd', function()
        models.set_current_model 'gpt-4.1'
        vim.notify('Switched to GPT-4.1 (Daily)', vim.log.levels.INFO)
      end, { desc = '[A]I [M]odel [D]aily (GPT-4.1)' })

      keymap('n', '<leader>amc', function()
        models.set_current_model 'claude-sonnet-4'
        vim.notify('Switched to Claude 4 Sonnet (Complex)', vim.log.levels.INFO)
      end, { desc = '[A]I [M]odel [C]omplex (Claude)' })

      keymap('n', '<leader>amf', function()
        models.set_current_model 'gpt-3.5-turbo'
        vim.notify('Switched to GPT-3.5 (Fast)', vim.log.levels.INFO)
      end, { desc = '[A]I [M]odel [F]ast (GPT-3.5)' })
    end
  end

  -- Create/Generate category - all <leader>ac* commands
  if ok_workflows and workflows then
    if type(workflows.create_component) == 'function' then
      keymap('n', '<leader>acr', workflows.create_component, { desc = '[A]I [C]reate [R]eact component' })
    end
    if type(workflows.create_hook) == 'function' then
      keymap('n', '<leader>ach', workflows.create_hook, { desc = '[A]I [C]reate [H]ook' })
    end
    if type(workflows.create_next_page) == 'function' then
      keymap('n', '<leader>acp', workflows.create_next_page, { desc = '[A]I [C]reate [P]age (Next.js)' })
    end

    keymap('n', '<leader>aca', function()
      if type(core.ask) == 'function' then
        core.ask 'Create a Next.js API route with proper TypeScript types, error handling, and validation.'
      end
    end, { desc = '[A]I [C]reate [A]PI (Next.js)' })

    keymap('n', '<leader>aci', function()
      if type(core.ask) == 'function' then
        core.ask 'Extract and create proper TypeScript interfaces for this code.'
      end
    end, { desc = '[A]I [C]reate [I]nterface' })

    keymap('n', '<leader>act', function()
      if type(core.ask) == 'function' then
        core.ask 'Create comprehensive test suite for this code with multiple test scenarios.'
      end
    end, { desc = '[A]I [C]reate [T]ests' })
  end

  -- Scan/Analyze category - all <leader>as* commands
  keymap('n', '<leader>asa', function()
    if ok_workflows and workflows and type(workflows.analyze_file) == 'function' then
      workflows.analyze_file()
    elseif type(core.ask) == 'function' then
      core.ask 'Analyze this entire file for bugs, performance issues, and improvements.'
    end
  end, { desc = '[A]I [S]can [A]ll issues' })

  keymap('n', '<leader>asp', function()
    if type(core.ask) == 'function' then
      core.ask [[Analyze this code for performance issues:
- Memory usage and leaks
- Algorithm efficiency
- Rendering performance (React)
- Bundle size impact
- Database query optimization
Provide specific optimizations with examples.]]
    end
  end, { desc = '[A]I [S]can [P]erformance' })

  keymap('n', '<leader>ass', function()
    if type(core.ask) == 'function' then
      core.ask [[Analyze for security vulnerabilities:
- XSS and injection attacks
- Authentication/authorization flaws
- Data exposure risks
- API security issues
- OWASP Top 10 compliance
Provide specific fixes for each issue found.]]
    end
  end, { desc = '[A]I [S]can [S]ecurity' })

  keymap('n', '<leader>asw', function()
    if type(core.ask) == 'function' then
      core.ask [[Analyze this code for accessibility (a11y) issues:
- Missing ARIA labels and roles
- Color contrast problems
- Keyboard navigation support
- Screen reader compatibility
- Focus management
Provide specific WCAG 2.1 compliant fixes.]]
    end
  end, { desc = '[A]I [S]can [W]CAG/A11y' })

  keymap('n', '<leader>ast', function()
    if type(core.ask) == 'function' then
      core.ask 'Find all TODOs, FIXMEs, and HACK comments in this code and suggest specific implementations.'
    end
  end, { desc = '[A]I [S]can [T]ODOs' })

  -- Workspace category - all <leader>aw* commands (if workspace module available)
  local ok_workspace, workspace = pcall(require, 'custom.ai-ultra.workspace')
  if ok_workspace and workspace then
    if type(workspace.ask_with_context) == 'function' then
      keymap({ 'n', 'v' }, '<leader>awc', function()
        workspace.ask_with_context 'Help me understand this code in the context of my project'
      end, { desc = '[A]I [W]orkspace [C]ontext help' })

      keymap('n', '<leader>awp', function()
        workspace.ask_with_context 'Analyze my project structure and suggest architectural improvements'
      end, { desc = '[A]I [W]orkspace [P]roject analysis' })

      keymap('n', '<leader>awr', function()
        workspace.ask_with_context 'Review my recent changes and suggest improvements'
      end, { desc = '[A]I [W]orkspace [R]eview changes' })

      keymap('n', '<leader>awt', function()
        workspace.ask_with_context "Analyze my project's testing strategy and suggest improvements"
      end, { desc = '[A]I [W]orkspace [T]esting strategy' })
    end
  end

  -- Help and utilities - all <leader>ah* commands
  keymap('n', '<leader>aha', function()
    if ok_workflows and workflows and type(workflows.contextual_help) == 'function' then
      workflows.contextual_help()
    elseif type(core.ask) == 'function' then
      core.ask 'Help me understand this code and provide guidance.'
    end
  end, { desc = '[A]I [H]elp [A]uto (contextual)' })

  keymap('n', '<leader>ahe', function()
    if ok_workflows and workflows and type(workflows.explain_error) == 'function' then
      workflows.explain_error()
    else
      local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })
      if #diagnostics > 0 then
        if type(core.ask) == 'function' then
          core.ask('Explain this error and provide a step-by-step fix:\n' .. diagnostics[1].message)
        end
      else
        vim.notify('No error at current line', vim.log.levels.INFO)
      end
    end
  end, { desc = '[A]I [H]elp [E]rror' })

  keymap('n', '<leader>ahd', function()
    local context = type(core.get_context) == 'function' and core.get_context() or {}
    local current_model = ok_models and type(models.get_current_model) == 'function' and models.get_current_model() or 'unknown'
    local usage = ok_models and type(models.get_usage_info) == 'function' and models.get_usage_info() or 'unavailable'

    local debug_info = {
      '=== AI Ultra Debug Information ===',
      '',
      'Current Model: ' .. current_model,
      'Usage: ' .. usage,
      '',
      'Context:',
      '  File: ' .. (context.filename or 'unknown'),
      '  Type: ' .. (context.filetype or 'unknown'),
      '  Framework: ' .. (context.framework or 'none'),
      '  Is Test: ' .. tostring(context.is_test or false),
      '  In Function: ' .. tostring(context.in_function or false),
      '  Function: ' .. (context.function_name or 'none'),
      '  Has Diagnostics: ' .. tostring(context.has_diagnostics or false),
      '  Line Count: ' .. (context.line_count or 0),
      '  Project: ' .. vim.fn.fnamemodify(context.project_root or vim.fn.getcwd(), ':t'),
    }

    vim.notify(table.concat(debug_info, '\n'), vim.log.levels.INFO)
  end, { desc = '[A]I [H]elp [D]ebug info' })

  keymap({ 'n', 'v' }, '<leader>aq', function()
    if ok_workflows and workflows and type(workflows.smart_menu) == 'function' then
      workflows.smart_menu()
    else
      vim.ui.select({ 'Explain', 'Fix', 'Review', 'Tests', 'Docs' }, { prompt = 'AI Quick Action:' }, function(choice)
        if choice then
          core.quick_action(choice:lower())
        end
      end)
    end
  end, { desc = 'AI Ultra: Quick Actions' })

  keymap({ 'n', 'v' }, '<leader>ab', function()
    local context = type(core.get_context) == 'function' and core.get_context() or {}
    local suggestions = {}

    -- Context-aware suggestions based on file type and framework
    if context.filetype == 'javascript' or context.filetype == 'typescript' then
      table.insert(suggestions, 'Add TypeScript types')
      table.insert(suggestions, 'Optimize bundle size')
      if context.framework == 'react' then
        table.insert(suggestions, 'Optimize re-renders')
        table.insert(suggestions, 'Extract custom hook')
      end
    elseif context.filetype == 'python' then
      table.insert(suggestions, 'Add type hints')
      table.insert(suggestions, 'Improve error handling')
    elseif context.filetype == 'go' then
      table.insert(suggestions, 'Add error handling')
      table.insert(suggestions, 'Optimize goroutines')
    end

    if context.has_diagnostics then
      table.insert(suggestions, 1, 'Fix current errors')
    end

    if #suggestions == 0 then
      suggestions = { 'Explain code', 'Fix issues', 'Add tests', 'Optimize performance' }
    end

    vim.ui.select(suggestions, {
      prompt = 'AI Smart Suggestions:',
    }, function(choice)
      if choice and type(core.ask) == 'function' and type(core.smart_selection) == 'function' then
        core.ask('Please ' .. choice:lower() .. ' for this code.', {
          selection = core.smart_selection(),
        })
      end
    end)
  end, { desc = 'AI Ultra: Smart Suggestions' })

  -- Command palette - Leader+ap
  keymap('n', '<leader>ap', function()
    local commands = {
      {
        label = '🔍 AI: Explain Code',
        action = function()
          core.quick_action 'explain'
        end,
      },
      {
        label = '🐛 AI: Fix Issues',
        action = function()
          core.quick_action 'fix'
        end,
      },
      {
        label = '🧪 AI: Generate Tests',
        action = function()
          core.quick_action 'tests'
        end,
      },
      {
        label = '📚 AI: Add Documentation',
        action = function()
          core.quick_action 'docs'
        end,
      },
      {
        label = '🔬 AI: Code Review',
        action = function()
          core.quick_action 'review'
        end,
      },
      {
        label = '⚡ AI: Optimize Performance',
        action = function()
          core.quick_action 'optimize'
        end,
      },
      {
        label = '🔄 AI: Refactor Code',
        action = function()
          core.quick_action 'refactor'
        end,
      },
      { label = '────────────────', action = nil },
      {
        label = '📝 Git: Smart Commit',
        action = (ok_workflows and workflows and type(workflows.smart_commit) == 'function') and workflows.smart_commit or nil,
      },
      {
        label = '🤖 Switch AI Model',
        action = (ok_workflows and workflows and type(workflows.model_menu) == 'function') and workflows.model_menu or nil,
      },
      {
        label = '💬 Toggle AI Chat',
        action = function()
          vim.cmd 'CopilotChatToggle'
        end,
      },
    }

    vim.ui.select(commands, {
      prompt = '🎯 AI Ultra Command Palette:',
      format_item = function(item)
        return item.label
      end,
    }, function(choice)
      if choice and choice.action then
        choice.action()
      end
    end)
  end, { desc = '[A]I [P]alette' })

  -- ============================================================================
  -- WHICH-KEY GROUPS (Clean organization)
  -- ============================================================================

  local ok_which_key, which_key = pcall(require, 'which-key')
  if ok_which_key then
    which_key.add {
      -- Main categories with clear descriptions
      { '<leader>a', group = '[A]I Ultra Assistant', mode = { 'n', 'v' } },
      { '<leader>ag', group = '[A]I [G]it Operations', mode = { 'n' } },
      { '<leader>am', group = '[A]I [M]odel Management', mode = { 'n' } },
      { '<leader>ac', group = '[A]I [C]reate/Generate', mode = { 'n' } },
      { '<leader>as', group = '[A]I [S]can/Analyze', mode = { 'n' } },
      { '<leader>aw', group = '[A]I [W]orkspace Context', mode = { 'n', 'v' } },
      { '<leader>ah', group = '[A]I [H]elp/Debug', mode = { 'n' } },
    }
  end

  vim.notify('AI Ultra: Keymaps loaded (conflict-free, tmux-safe)', vim.log.levels.INFO)
end

return M
