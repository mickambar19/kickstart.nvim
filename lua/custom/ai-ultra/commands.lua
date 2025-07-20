local M = {}

function M.setup()
  local core = require 'custom.ai-ultra.core'
  local ok_workflows, workflows = pcall(require, 'custom.ai-ultra.workflows')
  local ok_models, models = pcall(require, 'custom.ai-ultra.models')
  local ok_prompts, prompts = pcall(require, 'custom.ai-ultra.prompts')

  -- ============================================================================
  -- CORE AI COMMANDS
  -- ============================================================================

  -- Main AI command with smart context detection
  vim.api.nvim_create_user_command('AI', function(args)
    if args.args == '' then
      if ok_workflows then
        workflows.smart_menu()
      else
        vim.notify('Use :AI <prompt> to ask a question', vim.log.levels.INFO)
      end
    else
      core.ask(args.args, { selection = core.smart_selection() })
    end
  end, {
    nargs = '*',
    desc = 'AI Ultra: Ask AI or open smart menu',
    complete = function(arg_lead)
      local completions = {
        'explain this code',
        'fix issues in this code',
        'add tests for this code',
        'optimize this code for performance',
        'add documentation to this code',
        'review this code for issues',
        'refactor this code for maintainability',
        'add TypeScript types to this code',
        'modernize this code with latest features',
        'analyze security vulnerabilities',
        'check accessibility compliance',
      }
      return vim.tbl_filter(function(item)
        return item:match('^' .. vim.pesc(arg_lead))
      end, completions)
    end,
  })

  -- Quick action commands
  local quick_actions = {
    { cmd = 'AIExplain', action = 'explain', desc = 'AI Ultra: Explain code' },
    { cmd = 'AIFix', action = 'fix', desc = 'AI Ultra: Fix issues' },
    { cmd = 'AITest', action = 'tests', desc = 'AI Ultra: Generate tests' },
    { cmd = 'AIDocs', action = 'docs', desc = 'AI Ultra: Add documentation' },
    { cmd = 'AIReview', action = 'review', desc = 'AI Ultra: Review code' },
    { cmd = 'AIOptimize', action = 'optimize', desc = 'AI Ultra: Optimize performance' },
    { cmd = 'AIRefactor', action = 'refactor', desc = 'AI Ultra: Refactor code' },
    { cmd = 'AITypes', action = 'types', desc = 'AI Ultra: Add TypeScript types' },
  }

  for _, action in ipairs(quick_actions) do
    vim.api.nvim_create_user_command(action.cmd, function()
      core.quick_action(action.action)
    end, { desc = action.desc })
  end

  -- ============================================================================
  -- ENHANCED TEST GENERATION (Anti-truncation)
  -- ============================================================================

  -- Comprehensive test generation with anti-truncation
  vim.api.nvim_create_user_command('AITestComplete', function(args)
    local selection = core.smart_selection()
    local context = core.get_context()

    -- Enhanced prompt for comprehensive testing
    local test_prompt = string.format(
      [[Generate a COMPLETE comprehensive test suite for this %s code.

**CRITICAL ANTI-TRUNCATION REQUIREMENTS:**
- You MUST provide the ENTIRE test file with ALL implementations
- Complete every test function you start - never truncate
- Include ALL imports, setup, teardown, and configurations
- If response would be very long, that's required and expected
- Quality over brevity - provide complete, working test suites

## Required Test Structure:

### 1. Complete File Header
```%s
// All necessary imports
import { describe, it, expect, beforeEach, afterEach, jest } from '@jest/globals';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
// ... all other imports

// Mock configurations
jest.mock('...');
```

### 2. Complete Test Categories Required:

#### Happy Path Tests (Normal Usage)
- All successful operation scenarios
- Expected inputs and outputs
- Valid data flows
- Standard use cases

#### Edge Case Tests (Boundary Conditions)
- Empty/null/undefined inputs
- Minimum/maximum values
- Boundary conditions
- Large datasets
- Special characters

#### Error Handling Tests
- Invalid input types
- Network failures
- Exception scenarios
- Timeout conditions
- Resource unavailability

#### Integration Tests (if applicable)
- Component interactions
- External API mocks
- Database operations
- File system operations

#### Performance Tests (if relevant)
- Load testing
- Memory usage
- Rendering performance
- Timeout validation

### 3. Implementation Requirements:
- Use descriptive test names with "should..." pattern
- Clear arrange/act/assert structure
- Meaningful assertion messages
- Proper mock configurations
- Complete setup and teardown

**PROVIDE THE COMPLETE TEST FILE - FINISH ALL IMPLEMENTATIONS**]],
      context.filetype,
      context.filetype == 'typescript' and 'typescript' or 'javascript'
    )

    core.ask(test_prompt, {
      selection = selection,
      system_prompt = [[You are a comprehensive testing expert. Your mission is to create complete, production-ready test suites.

CRITICAL RULES:
1. NEVER truncate test code or explanations
2. ALWAYS provide complete test file implementations
3. Include ALL test categories mentioned in the prompt
4. Complete every test function you start writing
5. Provide full mock setups and configurations
6. If a response would be very long, that's perfectly fine and expected

Your goal is to create test suites that provide excellent coverage and are immediately usable in production.]],
    })
  end, {
    desc = 'AI Ultra: Generate complete comprehensive test suite (anti-truncation)',
    range = true,
  })

  -- Chunked test generation for very large suites
  vim.api.nvim_create_user_command('AITestChunked', function(args)
    local selection = core.smart_selection()

    local chunks = {
      {
        title = 'Test Structure & Setup',
        prompt = [[Provide the complete test file foundation:

**Part 1 of 4: Test Structure & Setup**

1. **Complete Imports Section**
   - All testing framework imports
   - Module under test imports
   - Mock library imports
   - Utility imports

2. **Global Test Configuration**
   - Jest/testing framework setup
   - Global mocks and spies
   - Test environment configuration
   - Common test utilities

3. **Test Suite Structure**
   - Main describe block
   - Nested describe blocks for categories
   - beforeEach/afterEach setup
   - Global test state management

4. **Mock Configurations**
   - External dependency mocks
   - API endpoint mocks
   - Module mocks
   - Spy configurations

Provide complete, working setup code that other test parts can build upon.]],
      },
      {
        title = 'Happy Path & Core Functionality Tests',
        prompt = [[Now implement all happy path and core functionality tests:

**Part 2 of 4: Happy Path & Core Tests**

Implement complete test functions for:

1. **Normal Usage Scenarios**
   - Standard input/output testing
   - Expected behavior validation
   - Successful operation flows

2. **Core Functionality Tests**
   - Primary feature testing
   - Main use case validation
   - Integration with dependencies

3. **Data Flow Tests**
   - Input processing validation
   - Output format verification
   - State change verification

Provide complete test implementations with full arrange/act/assert patterns.]],
      },
      {
        title = 'Edge Cases & Error Handling Tests',
        prompt = [[Implement all edge cases and error handling tests:

**Part 3 of 4: Edge Cases & Error Handling**

Implement complete test functions for:

1. **Boundary Value Tests**
   - Empty inputs (null, undefined, empty arrays/objects)
   - Minimum and maximum values
   - Zero and negative values
   - Large dataset handling

2. **Error Handling Tests**
   - Invalid input types
   - Network failure scenarios
   - Exception throwing and catching
   - Timeout conditions
   - Resource unavailability

3. **Resilience Tests**
   - Graceful degradation
   - Fallback behavior
   - Recovery mechanisms

Provide complete error test implementations with proper error assertions.]],
      },
      {
        title = 'Integration & Performance Tests',
        prompt = [[Complete the test suite with integration and performance tests:

**Part 4 of 4: Integration & Performance Tests**

Implement final test functions for:

1. **Integration Tests**
   - Component interaction testing
   - External API integration
   - Database operation testing
   - File system operations

2. **Performance Tests**
   - Execution time validation
   - Memory usage testing
   - Load testing scenarios
   - Rendering performance (if applicable)

3. **Test Suite Completion**
   - Any remaining test scenarios
   - Test coverage validation
   - Final test cleanup
   - Test documentation

Provide complete implementations that finalize the comprehensive test suite.]],
      },
    }

    local function execute_chunk(index)
      if index > #chunks then
        vim.notify('🎉 Complete test suite generation finished!', vim.log.levels.INFO)
        return
      end

      local chunk = chunks[index]
      vim.notify(string.format('🧪 Generating %s (%d/%d)', chunk.title, index, #chunks), vim.log.levels.INFO)

      core.ask(chunk.prompt, {
        selection = selection,
        callback = function(response)
          vim.schedule(function()
            vim.defer_fn(function()
              if index < #chunks then
                local continue =
                  vim.fn.confirm(string.format('Generated %s. Continue to %s?', chunk.title, chunks[index + 1].title), '&Yes\n&No\n&Regenerate current', 1)

                if continue == 1 then
                  execute_chunk(index + 1)
                elseif continue == 3 then
                  execute_chunk(index)
                end
              else
                vim.notify('🎉 Test suite generation complete!', vim.log.levels.INFO)
              end
            end, 1000)
          end)
        end,
      })
    end

    execute_chunk(1)
  end, { desc = 'AI Ultra: Generate tests in manageable chunks' })

  -- ============================================================================
  -- ANTI-TRUNCATION COMMANDS
  -- ============================================================================

  -- Continue truncated responses
  vim.api.nvim_create_user_command('AIContinue', function(args)
    local prompt = args.args ~= '' and args.args
      or 'Continue your previous response from exactly where you left off. Complete any unfinished code blocks, functions, or explanations. Provide the remaining content without repeating what you already provided.'

    require('CopilotChat').ask(prompt)
  end, {
    nargs = '*',
    desc = 'AI Ultra: Continue truncated response',
  })

  vim.api.nvim_create_user_command('AIComplete', function(args)
    local section = args.args
    local prompt = string.format(
      [[Your previous response appears to be incomplete. Please complete the %s section.

Provide the missing content including:
- Any unfinished code blocks or functions
- Complete implementations for all mentioned items
- Full explanations for any partial descriptions
- All remaining examples or test cases

Focus on completing what was started without repeating already provided content.]],
      section
    )

    require('CopilotChat').ask(prompt)
  end, {
    nargs = 1,
    complete = function(arg_lead)
      return vim.tbl_filter(function(item)
        return item:match('^' .. vim.pesc(arg_lead))
      end, { 'code block', 'test cases', 'function', 'explanation', 'imports', 'setup', 'mocks', 'documentation' })
    end,
    desc = 'AI Ultra: Complete specific section',
  })

  vim.api.nvim_create_user_command('AIFinish', function()
    require('CopilotChat').ask [[Please finish your previous response completely:

1. Complete any code blocks that were cut off
2. Finish any explanations that ended mid-sentence
3. Provide any missing implementations mentioned
4. Complete all examples or test cases that were started
5. Ensure all sections are fully implemented

Provide only the missing/incomplete content to finish your previous response.]]
  end, { desc = 'AI Ultra: Finish incomplete response' })

  -- ============================================================================
  -- MODEL MANAGEMENT COMMANDS
  -- ============================================================================

  if ok_models then
    vim.api.nvim_create_user_command('AIModel', function(args)
      if args.args == '' then
        workflows.model_menu()
      else
        local model_name = args.args
        if models.set_current_model(model_name) then
          vim.notify('Switched to ' .. model_name, vim.log.levels.INFO)
        end
      end
    end, {
      nargs = '?',
      complete = function()
        local model_names = {}
        for _, model in ipairs(models.models) do
          table.insert(model_names, model.name)
        end
        return model_names
      end,
      desc = 'AI Ultra: Model management',
    })

    vim.api.nvim_create_user_command('AIUsage', function()
      models.show_usage_stats()
    end, { desc = 'AI Ultra: Show model usage statistics' })

    -- Quick model switching
    vim.api.nvim_create_user_command('AIDaily', function()
      models.set_current_model 'gpt-4.1'
      vim.notify('Switched to GPT-4.1 (Daily)', vim.log.levels.INFO)
    end, { desc = 'AI Ultra: Switch to daily model (GPT-4.1)' })

    vim.api.nvim_create_user_command('AIComplex', function()
      models.set_current_model 'claude-sonnet-4'
      vim.notify('Switched to Claude 4 Sonnet (Complex)', vim.log.levels.INFO)
    end, { desc = 'AI Ultra: Switch to complex model (Claude)' })

    vim.api.nvim_create_user_command('AIFast', function()
      models.set_current_model 'gpt-3.5-turbo'
      vim.notify('Switched to GPT-3.5 (Fast)', vim.log.levels.INFO)
    end, { desc = 'AI Ultra: Switch to fast model (GPT-3.5)' })
  end

  -- ============================================================================
  -- GIT INTEGRATION COMMANDS
  -- ============================================================================

  if ok_workflows then
    vim.api.nvim_create_user_command('AICommit', workflows.smart_commit, {
      desc = 'AI Ultra: Generate smart commit message',
    })

    vim.api.nvim_create_user_command('AIDiff', function(args)
      local diff_type = args.args == 'staged' and '--cached' or ''
      local diff = vim.fn.system('git diff ' .. diff_type)

      if diff == '' then
        vim.notify('No ' .. (diff_type == '--cached' and 'staged' or 'unstaged') .. ' changes found', vim.log.levels.WARN)
        return
      end

      core.ask('Review these git changes and suggest improvements:\n\n' .. diff)
    end, {
      nargs = '?',
      complete = function()
        return { 'staged' }
      end,
      desc = 'AI Ultra: Review git diff',
    })

    vim.api.nvim_create_user_command('AIGitAnalyze', function()
      local log = vim.fn.system 'git log --oneline -10'
      if log ~= '' then
        core.ask('Analyze these recent commits for patterns, quality, and suggestions:\n\n' .. log)
      else
        vim.notify('No git history found', vim.log.levels.WARN)
      end
    end, { desc = 'AI Ultra: Analyze git history' })
  end

  -- ============================================================================
  -- SPECIALIZED ANALYSIS COMMANDS
  -- ============================================================================

  vim.api.nvim_create_user_command('AISecurity', function()
    core.ask [[Perform comprehensive security analysis of this code:

## Security Assessment Areas:

### 1. Input Validation & Sanitization
- SQL injection vulnerabilities
- XSS (Cross-Site Scripting) risks
- Command injection possibilities
- Path traversal vulnerabilities
- Input validation gaps

### 2. Authentication & Authorization
- Authentication bypass risks
- Authorization flaws
- Session management issues
- Token handling problems
- Privilege escalation risks

### 3. Data Protection
- Sensitive data exposure
- Encryption implementation
- Data transmission security
- Storage security
- Privacy compliance

### 4. API Security
- Rate limiting implementation
- CORS configuration
- HTTP security headers
- API versioning security
- Error information disclosure

### 5. OWASP Top 10 Compliance
Review against current OWASP Top 10 web application security risks.

Provide specific, actionable fixes for each vulnerability found.]]
  end, { desc = 'AI Ultra: Security audit' })

  vim.api.nvim_create_user_command('AIAccessibility', function()
    core.ask [[Audit this code for accessibility (a11y) compliance:

## Accessibility Assessment:

### 1. WCAG 2.1 AA Compliance
- Perceivable: Text alternatives, captions, color usage
- Operable: Keyboard access, seizure safety, navigation
- Understandable: Readable, predictable, input assistance
- Robust: Compatible with assistive technologies

### 2. Screen Reader Compatibility
- ARIA labels and descriptions
- ARIA roles and properties
- ARIA live regions
- Screen reader navigation
- Alternative text for images

### 3. Keyboard Navigation
- Tab order and focus management
- Keyboard shortcuts
- Focus indicators
- Skip navigation links
- Keyboard traps

### 4. Visual Accessibility
- Color contrast ratios
- Text scaling support
- Motion and animation control
- Visual focus indicators
- High contrast mode support

### 5. Mobile Accessibility
- Touch target sizes
- Gesture alternatives
- Orientation support
- Zoom functionality

Provide specific WCAG 2.1 compliant fixes for all issues found.]]
  end, { desc = 'AI Ultra: Accessibility audit' })

  vim.api.nvim_create_user_command('AIPerformance', function()
    core.ask [[Analyze this code for performance characteristics and optimizations:

## Performance Analysis:

### 1. Algorithm Analysis
- Time complexity assessment
- Space complexity evaluation
- Algorithm efficiency improvements
- Data structure optimization opportunities

### 2. Framework-Specific Performance
- React: Re-render optimization, memo usage, hook dependencies
- Database: Query optimization, N+1 problems, indexing
- JavaScript: Bundle size, tree shaking, code splitting
- Python: GIL considerations, async opportunities

### 3. Resource Usage
- Memory allocation patterns
- CPU usage optimization
- I/O operation efficiency
- Network request optimization
- Caching opportunities

### 4. Scalability Considerations
- Load handling capabilities
- Concurrent user support
- Database scalability
- Memory usage at scale
- Performance under stress

### 5. Benchmarking Recommendations
- Performance testing strategies
- Metrics to monitor
- Optimization validation methods
- Performance regression prevention

Provide specific, measurable optimization recommendations with expected performance gains.]]
  end, { desc = 'AI Ultra: Performance analysis' })

  -- ============================================================================
  -- WORKSPACE & PROJECT COMMANDS
  -- ============================================================================

  local ok_workspace, workspace = pcall(require, 'custom.ai-ultra.workspace')
  if ok_workspace then
    vim.api.nvim_create_user_command('AIProject', function()
      workspace.ask_with_context 'Analyze my project structure, architecture, and suggest improvements for maintainability and scalability.'
    end, { desc = 'AI Ultra: Project analysis' })

    vim.api.nvim_create_user_command('AIContext', function()
      local context = workspace.get_project_context()
      local lines = { '🏗️ Project Context Information:' }

      table.insert(lines, '📁 Project: ' .. (context.project_type or 'unknown'))
      table.insert(lines, '📍 Root: ' .. context.root)
      if context.git_root ~= '' then
        table.insert(lines, '🔀 Git: ' .. context.git_root)
      end
      if next(context.recent_changes) then
        table.insert(lines, '📝 Recent commits:')
        for i, change in ipairs(context.recent_changes) do
          if i <= 5 then
            table.insert(lines, '  ' .. change)
          end
        end
      end

      vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
    end, { desc = 'AI Ultra: Show project context' })
  end

  -- ============================================================================
  -- UTILITY & DEBUG COMMANDS
  -- ============================================================================

  vim.api.nvim_create_user_command('AIHealth', function()
    local health = {
      '🏥 AI Ultra Health Check',
      string.rep('=', 30),
      '',
    }

    -- Core health
    local core_health = core.health_check()
    table.insert(health, '🧠 Core Module:')
    table.insert(health, '  ✅ Core functionality: ' .. (core_health.core and 'OK' or 'FAIL'))
    table.insert(health, '  ' .. (core_health.treesitter and '✅' or '⚠️') .. ' Treesitter: ' .. (core_health.treesitter and 'Available' or 'Limited'))
    table.insert(
      health,
      '  ' .. (core_health.copilot_chat and '✅' or '❌') .. ' CopilotChat: ' .. (core_health.copilot_chat and 'Connected' or 'Unavailable')
    )
    table.insert(
      health,
      '  ' .. (core_health.context_detection and '✅' or '⚠️') .. ' Context Detection: ' .. (core_health.context_detection and 'Working' or 'Limited')
    )
    table.insert(health, '')

    -- Model health
    if ok_models then
      local model_health = models.health_check()
      table.insert(health, '🤖 Model Management:')
      table.insert(
        health,
        '  ' .. (model_health.state_file_accessible and '✅' or '❌') .. ' State File: ' .. (model_health.state_file_accessible and 'Accessible' or 'Error')
      )
      table.insert(
        health,
        '  ' .. (model_health.current_model_valid and '✅' or '❌') .. ' Current Model: ' .. (model_health.current_model_valid and 'Valid' or 'Invalid')
      )
      table.insert(
        health,
        '  '
          .. (model_health.usage_tracking_active and '✅' or '⚠️')
          .. ' Usage Tracking: '
          .. (model_health.usage_tracking_active and 'Active' or 'Inactive')
      )
      table.insert(health, '  📊 Current: ' .. (models.get_usage_info() or 'Unknown'))
    else
      table.insert(health, '⚠️ Model Management: Module not loaded')
    end
    table.insert(health, '')

    -- Module availability
    table.insert(health, '📦 Module Status:')
    table.insert(health, '  ' .. (ok_workflows and '✅' or '❌') .. ' Workflows: ' .. (ok_workflows and 'Loaded' or 'Failed'))
    table.insert(health, '  ' .. (ok_models and '✅' or '❌') .. ' Models: ' .. (ok_models and 'Loaded' or 'Failed'))
    table.insert(health, '  ' .. (ok_prompts and '✅' or '❌') .. ' Prompts: ' .. (ok_prompts and 'Loaded' or 'Failed'))
    table.insert(health, '  ' .. (ok_workspace and '✅' or '❌') .. ' Workspace: ' .. (ok_workspace and 'Loaded' or 'Failed'))

    vim.notify(table.concat(health, '\n'), vim.log.levels.INFO)
  end, { desc = 'AI Ultra: Health check' })

  vim.api.nvim_create_user_command('AIDebug', function()
    local context = core.get_context()
    local debug_info = {
      '🔍 AI Ultra Debug Information',
      string.rep('=', 35),
      '',
      '📄 Current File:',
      '  Path: ' .. context.relative_path,
      '  Type: ' .. context.filetype,
      '  Size: ' .. context.line_count .. ' lines',
      '  Framework: ' .. (context.framework or 'none'),
      '',
      '🎯 Context:',
      '  In Function: ' .. tostring(context.in_function),
      '  Function: ' .. (context.function_name or 'none'),
      '  Class: ' .. (context.class_name or 'none'),
      '  Is Test: ' .. tostring(context.is_test),
      '  Is Config: ' .. tostring(context.is_config),
      '',
      '🚨 Diagnostics:',
      '  Has Issues: ' .. tostring(context.has_diagnostics),
      '  Count: ' .. context.diagnostic_count,
      '',
      '🏗️ Project:',
      '  Root: ' .. context.project_root,
      '  Git: ' .. (context.git_root ~= '' and 'Yes' or 'No'),
    }

    if ok_models then
      table.insert(debug_info, '')
      table.insert(debug_info, '🤖 AI Model:')
      table.insert(debug_info, '  Current: ' .. models.get_current_model())
      table.insert(debug_info, '  Usage: ' .. models.get_usage_info())
    end

    vim.notify(table.concat(debug_info, '\n'), vim.log.levels.INFO)
  end, { desc = 'AI Ultra: Debug information' })

  -- ============================================================================
  -- QUICK PROMPT COMMANDS
  -- ============================================================================

  if ok_prompts then
    for name, prompt in pairs(prompts.quick_prompts) do
      local cmd_name = 'AI' .. name:gsub('^%l', string.upper)
      vim.api.nvim_create_user_command(cmd_name, function()
        core.ask(prompt, { selection = core.smart_selection() })
      end, { desc = 'AI Ultra: ' .. prompt:sub(1, 50) .. '...' })
    end
  end

  vim.notify('AI Ultra Commands: ' .. vim.tbl_count(vim.api.nvim_get_commands {}) .. ' commands registered', vim.log.levels.INFO)
end

return M
