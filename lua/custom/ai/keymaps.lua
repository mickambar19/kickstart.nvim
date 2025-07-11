local M = {}

function M.setup()
  local keymap = vim.keymap.set

  -- Safely require modules with error handling
  local ok_core, core = pcall(require, 'custom.ai.core')
  local ok_workflows, workflows = pcall(require, 'custom.ai.workflows')
  local ok_models, models = pcall(require, 'custom.ai.models')
  local ok_prompts, prompts = pcall(require, 'custom.ai.prompts')

  if not ok_core then
    vim.notify('Failed to load AI core: ' .. core, vim.log.levels.ERROR)
    return
  end

  if not ok_workflows then
    vim.notify('Failed to load AI workflows: ' .. workflows, vim.log.levels.ERROR)
    return
  end

  if not ok_models then
    vim.notify('Failed to load AI models: ' .. models, vim.log.levels.ERROR)
    return
  end

  -- ============================================================================
  -- MAIN AI MENU - Primary entry point
  -- ============================================================================
  keymap({ 'n', 'v' }, '<leader>ai', workflows.smart_menu, { desc = '[A]I Smart Menu' })

  -- ============================================================================
  -- INSTANT ACTIONS - Single letter suffixes (NO CONFLICTS)
  -- ============================================================================
  keymap({ 'n', 'v' }, '<leader>af', function()
    core.quick_action 'fix'
  end, { desc = '[A]I [F]ix' })

  keymap({ 'n', 'v' }, '<leader>ae', function()
    core.quick_action 'explain'
  end, { desc = '[A]I [E]xplain' })

  keymap({ 'n', 'v' }, '<leader>ao', function()
    core.quick_action 'optimize'
  end, { desc = '[A]I [O]ptimize' })

  keymap({ 'n', 'v' }, '<leader>av', function()
    core.quick_action 'review'
  end, { desc = '[A]I Re[v]iew' })

  keymap({ 'n', 'v' }, '<leader>ax', function()
    core.quick_action 'refactor'
  end, { desc = '[A]I Refactor (e[x]tract)' })

  keymap({ 'n', 'v' }, '<leader>ay', function()
    core.quick_action 'types'
  end, { desc = '[A]I T[y]pes' })

  keymap({ 'n', 'v' }, '<leader>ad', function()
    core.quick_action 'docs'
  end, { desc = '[A]I [D]ocs' })

  -- NEW: Custom ask prompt (single letter, no conflict)
  keymap({ 'n', 'v' }, '<leader>ak', function()
    local prompt = vim.fn.input 'Ask AI: '
    if prompt ~= '' then
      core.ask(prompt, { selection = core.smart_selection() })
    end
  end, { desc = '[A]I As[k] custom prompt' })

  -- ============================================================================
  -- CHAT MANAGEMENT - Simple single letters
  -- ============================================================================
  keymap('n', '<leader>aa', '<cmd>CopilotChatToggle<CR>', { desc = '[A]I Toggle Ch[a]t' })
  keymap('n', '<leader>ar', '<cmd>CopilotChatReset<CR>', { desc = '[A]I [R]eset Chat' })

  -- ============================================================================
  -- TESTING - Using 'at' prefix with double letters to avoid conflicts
  -- ============================================================================
  keymap({ 'n', 'v' }, '<leader>att', function()
    core.quick_action 'tests'
  end, { desc = '[A]I [T]ests [T]est' })

  keymap('n', '<leader>atf', workflows.test_current_function, { desc = '[A]I [T]est [F]unction' })

  -- ============================================================================
  -- CREATION - Using 'ac' prefix with double letters to avoid conflicts
  -- ============================================================================
  keymap('n', '<leader>acr', workflows.create_component, { desc = '[A]I [C]reate [R]eact component' })
  keymap('n', '<leader>ach', workflows.create_hook, { desc = '[A]I [C]reate [H]ook' })
  keymap('n', '<leader>acp', workflows.create_next_page, { desc = '[A]I [C]reate [P]age (Next.js)' })
  keymap('n', '<leader>aca', function()
    core.ask 'Create a Next.js API route with proper TypeScript types, error handling, and validation.'
  end, { desc = '[A]I [C]reate [A]PI (Next.js)' })

  keymap('n', '<leader>aci', function()
    core.ask 'Extract and create proper TypeScript interfaces for this code. Make them as specific as possible.'
  end, { desc = '[A]I [C]reate [I]nterface' })

  -- ============================================================================
  -- GIT - Using 'ag' prefix with double letters to avoid conflicts
  -- ============================================================================
  keymap('n', '<leader>agg', workflows.smart_commit, { desc = '[A]I [G]it [G]enerate commit' })

  keymap('n', '<leader>agr', function()
    local diff = vim.fn.system 'git diff'
    if diff == '' then
      diff = vim.fn.system 'git diff --cached'
    end
    if diff ~= '' then
      core.ask('Review these changes and suggest improvements:\n\n' .. diff)
    else
      vim.notify('No changes to review', vim.log.levels.WARN)
    end
  end, { desc = '[A]I [G]it [R]eview diff' })

  -- NEW: Deep git diff analysis
  keymap('n', '<leader>agd', function()
    local diff = vim.fn.system 'git diff'
    if diff == '' then
      diff = vim.fn.system 'git diff --cached'
    end
    if diff ~= '' then
      core.ask('Analyze these git changes for:\n1. Potential bugs\n2. Breaking changes\n3. Performance impact\n4. Security issues\n\n' .. diff)
    else
      vim.notify('No changes to analyze', vim.log.levels.WARN)
    end
  end, { desc = '[A]I [G]it [D]iff analyze' })

  -- ============================================================================
  -- MODELS - Using 'am' prefix with double letters to avoid conflicts
  -- ============================================================================
  keymap('n', '<leader>amm', workflows.model_menu, { desc = '[A]I [M]odel [M]enu' })
  keymap('n', '<leader>amu', models.show_usage_stats, { desc = '[A]I [M]odel [U]sage' })
  keymap('n', '<leader>amd', function()
    models.set_current_model 'gpt-4.1'
    vim.notify('Switched to GPT-4.1 (Daily)', vim.log.levels.INFO)
  end, { desc = '[A]I [M]odel [D]aily (GPT-4.1)' })
  keymap('n', '<leader>amc', function()
    models.set_current_model 'claude-sonnet-4'
    vim.notify('Switched to Claude 4 Sonnet (Complex)', vim.log.levels.INFO)
  end, { desc = '[A]I [M]odel [C]omplex (Claude)' })

  -- ============================================================================
  -- ANALYSIS/SCANNING - Using 'as' prefix with double letters to avoid conflicts
  -- ============================================================================
  keymap('n', '<leader>asa', workflows.analyze_file, { desc = '[A]I [S]can [A]ll issues' })
  keymap('n', '<leader>asp', function()
    core.ask [[Analyze this code for performance issues:
- Unnecessary re-renders (React)
- Memory leaks
- Inefficient algorithms
- Bundle size impact
Provide specific optimizations with examples.]]
  end, { desc = '[A]I [S]can [P]erformance' })
  keymap('n', '<leader>ass', function()
    core.ask [[Analyze for security vulnerabilities:
- XSS vulnerabilities
- SQL injection risks
- Authentication/authorization issues
- Sensitive data exposure
- OWASP Top 10
Provide specific fixes for each issue found.]]
  end, { desc = '[A]I [S]can [S]ecurity' })

  -- NEW: Accessibility analysis
  keymap('n', '<leader>asw', function()
    core.ask [[Analyze this code for accessibility (a11y) issues:
- Missing ARIA labels
- Color contrast problems  
- Keyboard navigation
- Screen reader compatibility
- Focus management
Provide specific WCAG 2.1 compliant fixes.]]
  end, { desc = '[A]I [S]can [W]CAG/A11y' })

  -- NEW: TODO analysis
  keymap('n', '<leader>ast', function()
    core.ask 'Find all TODOs, FIXMEs, and HACK comments in this code and suggest specific implementations for each.'
  end, { desc = '[A]I [S]can [T]ODOs' })

  -- ============================================================================
  -- HELP AND DIAGNOSTICS - Single letters to avoid conflicts
  -- ============================================================================
  keymap('n', '<leader>ah', workflows.contextual_help, { desc = '[A]I [H]elp (contextual)' })
  keymap('n', '<leader>a?', workflows.explain_error, { desc = '[A]I Explain error' })

  -- ============================================================================
  -- QUICK/UTILITY FUNCTIONS - Using different single letters to avoid conflicts
  -- ============================================================================

  -- Quick prompts menu (using 'q' - single letter, no sub-keymaps)
  keymap('n', '<leader>aq', function()
    if ok_prompts then
      local quick_keys = vim.tbl_keys(prompts.quick_prompts)
      vim.ui.select(quick_keys, {
        prompt = 'Select quick prompt:',
      }, function(choice)
        if choice then
          core.ask(prompts.quick_prompts[choice])
        end
      end)
    else
      vim.notify('Quick prompts not available', vim.log.levels.WARN)
    end
  end, { desc = '[A]I [Q]uick prompts menu' })

  -- Debug info (using 'b' - single letter, no sub-keymaps)
  keymap('n', '<leader>ab', function()
    local context = core.get_context()
    local current_model = models.get_current_model()
    local usage = models.get_usage_info()

    local debug_info = {
      '=== AI Debug Information ===',
      '',
      'Current Model: ' .. current_model,
      'Usage: ' .. usage,
      '',
      'Context:',
      '  File: ' .. context.filename,
      '  Type: ' .. context.filetype,
      '  Framework: ' .. (context.framework or 'none'),
      '  Is Test: ' .. tostring(context.is_test),
      '  In Function: ' .. tostring(context.in_function),
      '  Has Diagnostics: ' .. tostring(context.has_diagnostics),
      '',
      'Available Quick Prompts:',
    }

    if ok_prompts then
      for key, _ in pairs(prompts.quick_prompts) do
        table.insert(debug_info, '  ' .. key)
      end
    end

    vim.notify(table.concat(debug_info, '\n'), vim.log.levels.INFO)
  end, { desc = '[A]I De[b]ug info' })

  -- ============================================================================
  -- INDIVIDUAL QUICK ACTIONS - Using unused single letters
  -- ============================================================================

  -- Quick error analysis (using 'z' - no conflicts)
  keymap('n', '<leader>az', function()
    core.ask 'Explain this error and provide a step-by-step fix with examples.'
  end, { desc = '[A]I Error analy[z]e' })

  -- Quick performance (using 'p' - but need to check for conflicts with prompt history)
  -- Actually, let's use 'w' for performance (w = fast/quick)
  keymap('n', '<leader>aw', function()
    core.ask 'Analyze performance bottlenecks in this code and suggest specific optimizations.'
  end, { desc = '[A]I Performance (slo[w] → fast)' })

  -- Quick interface extraction (using 'i' - but checking conflicts)
  -- Let's use 'j' instead
  keymap('n', '<leader>aj', function()
    core.ask 'Extract and create proper TypeScript interfaces from this code with strict typing.'
  end, { desc = '[A]I Interface (o[j]ect)' })

  -- Quick generics (using 'u' - no conflicts)
  keymap('n', '<leader>au', function()
    core.ask 'Improve types using generics where appropriate. Make them more flexible and reusable.'
  end, { desc = '[A]I Generics (yo[u] type)' })

  -- ============================================================================
  -- EMERGENCY KEYS - Function keys for instant access
  -- ============================================================================
  keymap('n', '<F1>', workflows.contextual_help, { desc = 'AI Quick Help' })
  keymap({ 'n', 'v' }, '<F2>', function()
    core.quick_action 'fix'
  end, { desc = 'AI Quick Fix' })

  -- ============================================================================
  -- PROMPT HISTORY - Single letter to avoid conflicts
  -- ============================================================================
  keymap('n', '<leader>ap', function()
    vim.notify('Use :CopilotChatOpen to see chat history', vim.log.levels.INFO)
  end, { desc = '[A]I [P]rompt history' })

  vim.notify('AI keymaps loaded (complete, conflict-free)', vim.log.levels.INFO)
end

return M
