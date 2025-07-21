local M = {}

-- Enhanced smart selection with project context
function M.smart_selection()
  return function(source)
    -- Priority 1: Visual selection if active
    if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' or vim.fn.mode() == '\22' then
      return require('CopilotChat.select').visual(source)
    end

    -- Priority 2: Diagnostics on current line
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })
    if #diagnostics > 0 then
      return require('CopilotChat.select').diagnostics(source)
    end

    -- Priority 3: Function/method context using treesitter
    local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
    if ok then
      local node = ts_utils.get_node_at_cursor()
      if node then
        -- Find parent function/class/method
        local function_types = {
          'function_declaration',
          'function_definition',
          'method_definition',
          'arrow_function',
          'function_expression',
          'class_declaration',
          'interface_declaration',
          'type_alias_declaration',
        }

        local current = node
        while current do
          local node_type = current:type()
          if vim.tbl_contains(function_types, node_type) then
            -- Return function selection
            return function(src)
              local start_row, start_col, end_row, end_col = current:range()
              return src.bufnr, start_row, start_col, end_row, end_col
            end
          end
          current = current:parent()
        end
      end
    end

    -- Priority 4: Intelligent block selection
    local line = vim.fn.line '.'
    local col = vim.fn.col '.'

    -- Try to select logical blocks (class, function, etc.)
    local lines = vim.api.nvim_buf_get_lines(0, math.max(0, line - 10), line + 10, false)
    local current_indent = vim.fn.indent(line)

    -- Find block boundaries
    local start_line = line
    local end_line = line

    -- Look backward for block start
    for i = line - 1, math.max(1, line - 20), -1 do
      local line_indent = vim.fn.indent(i)
      local line_text = vim.fn.getline(i):match '^%s*(.-)%s*$'

      if line_indent < current_indent and line_text ~= '' then
        start_line = i
        break
      end
    end

    -- Look forward for block end
    for i = line + 1, math.min(vim.fn.line '$', line + 20) do
      local line_indent = vim.fn.indent(i)
      local line_text = vim.fn.getline(i):match '^%s*(.-)%s*$'

      if line_indent <= current_indent and line_text ~= '' then
        end_line = i - 1
        break
      end
    end

    -- If we found a reasonable block, select it
    if end_line > start_line and (end_line - start_line) < 50 then
      return function(src)
        return src.bufnr, start_line - 1, 0, end_line - 1, -1
      end
    end

    -- Priority 5: Current line
    return require('CopilotChat.select').line(source)
  end
end

-- Enhanced context detection with project awareness
function M.get_context()
  local context = {
    -- File information
    filename = vim.fn.expand '%:t',
    filepath = vim.fn.expand '%:p',
    relative_path = vim.fn.expand '%:.',
    filetype = vim.bo.filetype,

    -- Project information
    project_root = vim.fn.getcwd(),
    git_root = vim.fn.system('git rev-parse --show-toplevel 2>/dev/null'):gsub('\n', ''),

    -- File characteristics
    is_test = false,
    is_config = false,
    is_documentation = false,

    -- Code context
    framework = nil,
    language_info = {},
    in_function = false,
    function_name = nil,
    class_name = nil,

    -- Current state
    has_diagnostics = false,
    diagnostic_count = 0,
    cursor_position = { vim.fn.line '.', vim.fn.col '.' },

    -- File metrics
    line_count = vim.fn.line '$',
    file_size = vim.fn.getfsize(vim.fn.expand '%:p'),
  }

  -- Detect file types
  local filename_lower = context.filename:lower()
  context.is_test = filename_lower:match '%.test%.'
    or filename_lower:match '%.spec%.'
    or filename_lower:match '_test%.'
    or filename_lower:match '_spec%.'
    or filename_lower:match '/tests?/'
    or filename_lower:match '/spec/'

  context.is_config = filename_lower:match 'config'
    or filename_lower:match '%.config%.'
    or filename_lower:match '%.conf$'
    or filename_lower:match '%.json$'
    or filename_lower:match '%.yaml$'
    or filename_lower:match '%.yml$'

  context.is_documentation = filename_lower:match 'readme' or filename_lower:match '%.md$' or filename_lower:match '%.txt$' or filename_lower:match '/docs?/'

  -- Enhanced framework detection
  if context.filetype == 'typescriptreact' or context.filetype == 'javascriptreact' then
    -- Check for Next.js
    local cwd = vim.fn.getcwd()
    if
      vim.fn.filereadable(cwd .. '/next.config.js') == 1
      or vim.fn.filereadable(cwd .. '/next.config.ts') == 1
      or vim.fn.isdirectory(cwd .. '/pages') == 1
      or vim.fn.isdirectory(cwd .. '/app') == 1
    then
      context.framework = 'nextjs'
    else
      context.framework = 'react'
    end
  elseif context.filetype == 'typescript' or context.filetype == 'javascript' then
    -- Analyze imports and package.json for framework detection
    local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
    for _, line in ipairs(lines) do
      local trimmed = line:match '^%s*(.-)%s*$'
      if trimmed:match 'from [\'"]react[\'"]' or trimmed:match 'import.*React' then
        context.framework = 'react'
        break
      elseif trimmed:match 'from [\'"]express[\'"]' then
        context.framework = 'express'
        break
      elseif trimmed:match 'from [\'"]@nestjs' then
        context.framework = 'nestjs'
        break
      elseif trimmed:match 'from [\'"]vue[\'"]' then
        context.framework = 'vue'
        break
      elseif trimmed:match 'from [\'"]@angular' then
        context.framework = 'angular'
        break
      end
    end
  elseif context.filetype == 'python' then
    local lines = vim.api.nvim_buf_get_lines(0, 0, 30, false)
    for _, line in ipairs(lines) do
      local trimmed = line:match '^%s*(.-)%s*$'
      if trimmed:match 'from django' or trimmed:match 'import django' then
        context.framework = 'django'
        break
      elseif trimmed:match 'from flask' or trimmed:match 'import flask' then
        context.framework = 'flask'
        break
      elseif trimmed:match 'from fastapi' or trimmed:match 'import fastapi' then
        context.framework = 'fastapi'
        break
      end
    end
  elseif context.filetype == 'go' then
    local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
    for _, line in ipairs(lines) do
      if line:match 'github%.com/gin%-gonic/gin' then
        context.framework = 'gin'
        break
      elseif line:match 'github%.com/gorilla/mux' then
        context.framework = 'gorilla'
        break
      elseif line:match 'github%.com/labstack/echo' then
        context.framework = 'echo'
        break
      end
    end
  end

  -- Enhanced function/class context detection
  local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
  if ok then
    local node = ts_utils.get_node_at_cursor()
    if node then
      local current = node

      -- Find function context
      while current do
        local node_type = current:type()
        if
          vim.tbl_contains({
            'function_declaration',
            'function_definition',
            'method_definition',
            'arrow_function',
            'function_expression',
          }, node_type)
        then
          context.in_function = true
          context.function_name = M.extract_node_name(current)
          break
        elseif vim.tbl_contains({
          'class_declaration',
          'class_definition',
          'interface_declaration',
        }, node_type) then
          context.class_name = M.extract_node_name(current)
        end
        current = current:parent()
      end
    end
  end

  -- Diagnostics information
  local diagnostics = vim.diagnostic.get(0)
  context.has_diagnostics = #diagnostics > 0
  context.diagnostic_count = #diagnostics

  -- Language-specific information
  context.language_info = M.get_language_info(context.filetype)

  return context
end

-- Extract name from treesitter node
function M.extract_node_name(node)
  if not node then
    return 'unknown'
  end

  local lang = vim.bo.filetype
  local query_strings = {
    javascript = '(function_declaration name: (identifier) @name)',
    typescript = '(function_declaration name: (identifier) @name)',
    typescriptreact = '(function_declaration name: (identifier) @name)',
    javascriptreact = '(function_declaration name: (identifier) @name)',
    python = '(function_definition name: (identifier) @name)',
    go = '(function_declaration name: (identifier) @name)',
    lua = '(function_declaration name: (identifier) @name)',
  }

  local query_string = query_strings[lang]
  if not query_string then
    return 'unknown'
  end

  local ok, query = pcall(vim.treesitter.query.parse, lang, query_string)
  if not ok then
    return 'unknown'
  end

  local bufnr = vim.api.nvim_get_current_buf()
  for _, match, _ in query:iter_matches(node, bufnr) do
    for id, captured_node in pairs(match) do
      if query.captures[id] == 'name' then
        local ok_text, text = pcall(vim.treesitter.get_node_text, captured_node, bufnr)
        if ok_text then
          return text
        end
      end
    end
  end

  return 'unknown'
end

-- Get language-specific information
function M.get_language_info(filetype)
  local info = {
    paradigm = 'unknown',
    typing = 'unknown',
    common_patterns = {},
    testing_framework = 'unknown',
    package_manager = 'unknown',
  }

  if filetype == 'javascript' or filetype == 'typescript' or filetype == 'javascriptreact' or filetype == 'typescriptreact' then
    info.paradigm = 'multi-paradigm'
    info.typing = filetype:match 'typescript' and 'static' or 'dynamic'
    info.common_patterns = { 'async/await', 'promises', 'modules', 'destructuring' }
    info.testing_framework = 'jest'
    info.package_manager = 'npm'
  elseif filetype == 'python' then
    info.paradigm = 'multi-paradigm'
    info.typing = 'dynamic'
    info.common_patterns = { 'list comprehensions', 'decorators', 'context managers' }
    info.testing_framework = 'pytest'
    info.package_manager = 'pip'
  elseif filetype == 'go' then
    info.paradigm = 'procedural'
    info.typing = 'static'
    info.common_patterns = { 'interfaces', 'goroutines', 'channels', 'error handling' }
    info.testing_framework = 'testing'
    info.package_manager = 'go mod'
  elseif filetype == 'lua' then
    info.paradigm = 'multi-paradigm'
    info.typing = 'dynamic'
    info.common_patterns = { 'tables', 'metatables', 'coroutines' }
    info.testing_framework = 'busted'
    info.package_manager = 'luarocks'
  end

  return info
end

-- Enhanced AI request with context injection
function M.ask(prompt, opts)
  opts = opts or {}

  -- Get enhanced context
  local context = M.get_context()

  -- Auto-select appropriate selection method if not provided
  if not opts.selection then
    opts.selection = M.smart_selection()
  end

  -- Enhanced system prompt if not provided
  if not opts.system_prompt then
    local enhanced_system = string.format(
      [[You are an expert AI assistant with deep understanding of %s development.

Current context:
- File: %s (%s)
- Framework: %s
- Project: %s
- Function: %s
- Diagnostics: %d issues

Provide comprehensive, accurate responses with:
1. Complete working code examples
2. Proper error handling
3. Performance considerations
4. Security best practices
5. Testing strategies

Never truncate responses. Always complete your explanations and code examples.]],
      context.filetype,
      context.relative_path,
      context.filetype,
      context.framework or 'none',
      vim.fn.fnamemodify(context.project_root, ':t'),
      context.function_name or 'none',
      context.diagnostic_count
    )
    opts.system_prompt = enhanced_system
  end

  -- Track usage if models module is available
  local ok_models, models = pcall(require, 'custom.ai-ultra.models')
  if ok_models then
    local current_model = models.get_current_model()
    if current_model:match 'claude' then
      models.track_usage()
    end
  end

  -- Execute the AI request
  require('CopilotChat').ask(prompt, opts)
end

-- Quick action wrapper with enhanced prompts
function M.quick_action(action_name)
  local ok_prompts, prompts = pcall(require, 'custom.ai-ultra.prompts')
  if not ok_prompts then
    -- Fallback prompts if prompts module is unavailable
    local fallback_prompts = {
      explain = 'Explain this code clearly and comprehensively.',
      fix = 'Fix any issues in this code and explain the fixes.',
      optimize = 'Optimize this code for better performance.',
      review = 'Review this code for potential issues and improvements.',
      test = 'Generate comprehensive tests for this code.',
      docs = 'Add thorough documentation to this code.',
      refactor = 'Refactor this code for better maintainability.',
    }

    local prompt = fallback_prompts[action_name] or 'Analyze this code.'
    M.ask(prompt, { selection = M.smart_selection() })
    return
  end

  local context = M.get_context()
  local prompt_config = prompts.get_prompt(action_name, context)

  if not prompt_config then
    vim.notify('Unknown action: ' .. action_name, vim.log.levels.ERROR)
    return
  end

  M.ask(prompt_config.text, {
    selection = M.smart_selection(),
    system_prompt = prompt_config.system,
  })
end

-- Health check for AI Ultra core
function M.health_check()
  local health = {
    core = true,
    treesitter = false,
    copilot_chat = false,
    context_detection = false,
  }

  -- Check treesitter
  local ok_ts = pcall(require, 'nvim-treesitter.ts_utils')
  health.treesitter = ok_ts

  -- Check CopilotChat
  local ok_chat = pcall(require, 'CopilotChat')
  health.copilot_chat = ok_chat

  -- Check context detection
  local ok_context, context = pcall(M.get_context)
  health.context_detection = ok_context and context ~= nil

  return health
end

function M.setup()
  -- Core setup is handled by the main plugin
  -- This function exists for consistency with other modules
  vim.notify('AI Ultra Core: Ready', vim.log.levels.DEBUG)
end

return M
