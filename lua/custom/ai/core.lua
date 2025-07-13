local M = {}

-- Smart context detection
function M.smart_selection()
  -- Visual mode takes priority
  if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
    return require('CopilotChat.select').visual
  end

  -- Check for diagnostics on current line
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })
  if #diagnostics > 0 then
    return require('CopilotChat.select').diagnostics
  end

  -- Check if we're in a function/method
  local node = vim.treesitter.get_node()
  if node then
    local node_type = node:type()
    if vim.tbl_contains({ 'function_declaration', 'method_definition', 'arrow_function', 'function_expression' }, node_type) then
      -- Select the function
      return function(source)
        local start_row, start_col, end_row, end_col = node:range()
        return source.bufnr, start_row, start_col, end_row, end_col
      end
    end
  end

  -- Default to buffer
  return require('CopilotChat.select').buffer
end

-- Get current context (filetype, framework, etc.)
function M.get_context()
  local ft = vim.bo.filetype
  local context = {
    filetype = ft,
    filename = vim.fn.expand '%:t',
    filepath = vim.fn.expand '%:p',
    is_test = false,
    framework = nil,
    in_function = false,
    has_diagnostics = false,
  }

  -- Detect test files
  local filename = context.filename:lower()
  context.is_test = filename:match '%.test%.' or filename:match '%.spec%.' or filename:match '_test%.' or filename:match '_spec%.'

  -- Detect framework
  if ft == 'typescriptreact' or ft == 'javascriptreact' then
    -- Check for Next.js indicators
    local cwd = vim.fn.getcwd()
    if vim.fn.filereadable(cwd .. '/next.config.js') == 1 or vim.fn.filereadable(cwd .. '/next.config.ts') == 1 then
      context.framework = 'nextjs'
    else
      context.framework = 'react'
    end
  elseif ft == 'typescript' or ft == 'javascript' then
    -- Check imports for framework detection
    local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
    for _, line in ipairs(lines) do
      if line:match 'from [\'"]react[\'"]' then
        context.framework = 'react'
        break
      elseif line:match 'from [\'"]express[\'"]' then
        context.framework = 'express'
        break
      elseif line:match 'from [\'"]@nestjs' then
        context.framework = 'nestjs'
        break
      end
    end
  end

  -- Check if cursor is in a function
  local ok, node = pcall(vim.treesitter.get_node)
  if ok and node then
    local parent = node:parent()
    while parent do
      local ok_type, node_type = pcall(function()
        return parent:type()
      end)
      if ok_type and vim.tbl_contains({ 'function_declaration', 'method_definition', 'arrow_function' }, node_type) then
        context.in_function = true
        break
      end
      parent = parent:parent()
    end
  end

  -- Check for diagnostics
  context.has_diagnostics = #vim.diagnostic.get(0) > 0

  return context
end

-- Execute AI request with enhanced error handling
function M.ask(prompt, opts)
  opts = opts or {}
  opts.selection = opts.selection or M.smart_selection()

  -- Add context to system message if not provided
  if not opts.system_prompt then
    local context = M.get_context()
    local prompts = require 'custom.ai.prompts'
    opts.system_prompt = prompts.system_prompts.comprehensive
  end

  -- Add model info
  local models = require 'custom.ai.models'
  local current_model = models.get_current_model()

  -- Track usage for Claude models
  if current_model:match 'claude' then
    models.track_usage()
  end

  require('CopilotChat').ask(prompt, opts)
end

-- Quick action wrapper
function M.quick_action(action_name)
  local prompts = require 'custom.ai.prompts'
  local context = M.get_context()
  local prompt = prompts.get_prompt(action_name, context)

  if not prompt then
    vim.notify('Unknown action: ' .. action_name, vim.log.levels.ERROR)
    return
  end

  M.ask(prompt.text, {
    selection = M.smart_selection(),
    system_prompt = prompt.system,
  })
end

return M
