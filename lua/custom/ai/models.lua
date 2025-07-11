local M = {}

-- Available models
M.models = {
  {
    name = 'gpt-4.1',
    display = 'GPT-4.1 (Daily Driver)',
    limit = nil,
    description = 'Fast, reliable for daily tasks',
  },
  {
    name = 'claude-sonnet-4',
    display = 'Claude 4 Sonnet (Complex)',
    limit = 300,
    description = 'Superior for complex reasoning',
  },
  {
    name = 'gpt-3.5-turbo',
    display = 'GPT-3.5 (Fast)',
    limit = nil,
    description = 'Fastest responses, good for simple tasks',
  },
}

-- State persistence file
local state_file = vim.fn.stdpath 'data' .. '/ai_model_state.json'

-- Default state
local default_state = {
  current_model = 'gpt-4.1',
  usage = {
    ['claude-sonnet-4'] = {
      count = 0,
      last_reset = os.date '%Y-%m-01',
    },
  },
}

-- Load state from file
function M.load_state()
  if vim.fn.filereadable(state_file) == 1 then
    local content = vim.fn.readfile(state_file)
    if #content > 0 then
      local ok, state = pcall(vim.fn.json_decode, table.concat(content, '\n'))
      if ok and type(state) == 'table' then
        return state
      end
    end
  end
  return vim.deepcopy(default_state)
end

-- Save state to file
function M.save_state(state)
  local ok, content = pcall(vim.fn.json_encode, state)
  if ok then
    vim.fn.writefile({ content }, state_file)
  else
    vim.notify('Failed to save AI model state', vim.log.levels.ERROR)
  end
end

-- Get current model
function M.get_current_model()
  local state = M.load_state()
  return state.current_model or 'gpt-4.1'
end

-- Set current model
function M.set_current_model(model_name)
  local state = M.load_state()

  -- Validate model exists
  local valid = false
  for _, model in ipairs(M.models) do
    if model.name == model_name then
      valid = true
      break
    end
  end

  if not valid then
    vim.notify('Invalid model: ' .. model_name, vim.log.levels.ERROR)
    return false
  end

  state.current_model = model_name
  M.save_state(state)

  -- Update CopilotChat model
  local ok, copilot_chat = pcall(require, 'CopilotChat')
  if ok then
    copilot_chat.setup { model = model_name }
  end

  return true
end

-- Track usage for limited models
function M.track_usage(model_name)
  model_name = model_name or M.get_current_model()
  local state = M.load_state()

  -- Only track models with limits
  local model_info = nil
  for _, model in ipairs(M.models) do
    if model.name == model_name and model.limit then
      model_info = model
      break
    end
  end

  if not model_info then
    return
  end

  -- Initialize usage if needed
  if not state.usage[model_name] then
    state.usage[model_name] = {
      count = 0,
      last_reset = os.date '%Y-%m-01',
    }
  end

  -- Check if we need to reset monthly counter
  local current_month = os.date '%Y-%m-01'
  if state.usage[model_name].last_reset ~= current_month then
    state.usage[model_name] = {
      count = 0,
      last_reset = current_month,
    }
  end

  -- Increment usage
  state.usage[model_name].count = state.usage[model_name].count + 1

  -- Warn if approaching limit
  local usage = state.usage[model_name].count
  local limit = model_info.limit

  if usage >= limit then
    vim.notify(string.format('⚠️  %s limit reached! (%d/%d this month)\nSwitching to GPT-4.1...', model_info.display, usage, limit), vim.log.levels.WARN)
    M.set_current_model 'gpt-4.1'
  elseif usage >= limit * 0.8 then
    vim.notify(
      string.format('⚠️  %s usage at %d%% (%d/%d this month)', model_info.display, math.floor(usage / limit * 100), usage, limit),
      vim.log.levels.WARN
    )
  end

  M.save_state(state)
end

-- Get usage info for current model
function M.get_usage_info()
  local state = M.load_state()
  local current = M.get_current_model()

  -- Find model info
  local model_info = nil
  for _, model in ipairs(M.models) do
    if model.name == current then
      model_info = model
      break
    end
  end

  if not model_info then
    return 'Unknown model'
  end

  if not model_info.limit then
    return string.format('%s (Unlimited)', model_info.display)
  end

  -- Get usage
  local usage_data = state.usage[current] or { count = 0 }
  local percentage = math.floor(usage_data.count / model_info.limit * 100)

  return string.format('%s (%d/%d - %d%%)', model_info.display, usage_data.count, model_info.limit, percentage)
end

-- Show usage statistics
function M.show_usage_stats()
  local state = M.load_state()
  local lines = { 'AI Model Usage Statistics', '' }

  for _, model in ipairs(M.models) do
    if model.limit then
      local usage_data = state.usage[model.name] or { count = 0 }
      local percentage = math.floor(usage_data.count / model.limit * 100)
      table.insert(lines, string.format('%s: %d/%d (%d%%)', model.display, usage_data.count, model.limit, percentage))
    else
      table.insert(lines, string.format('%s: Unlimited', model.display))
    end
  end

  table.insert(lines, '')
  table.insert(lines, 'Current model: ' .. M.get_current_model())

  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end

-- Smart model selection based on task complexity
function M.suggest_model(task_type)
  local suggestions = {
    simple = 'gpt-3.5-turbo',
    daily = 'gpt-4.1',
    complex = 'claude-sonnet-4',
  }

  local model = suggestions[task_type] or 'gpt-4.1'

  -- Check if suggested model has capacity
  if task_type == 'complex' then
    local state = M.load_state()
    local usage_data = state.usage['claude-sonnet-4'] or { count = 0 }
    if usage_data.count >= 300 then
      model = 'gpt-4.1'
      vim.notify('Claude limit reached, using GPT-4.1 instead', vim.log.levels.INFO)
    end
  end

  return model
end

return M
