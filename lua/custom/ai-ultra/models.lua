local M = {}

M.models = {
  {
    name = 'gpt-4.1',
    display = 'GPT-4.1 (Daily Driver)',
    provider = 'OpenAI',
    limit = nil,
    cost_per_1k = 0.03,
    context_window = 128000,
    strengths = { 'Fast responses', 'Code generation', 'General tasks' },
    best_for = { 'daily coding', 'quick fixes', 'explanations' },
    description = 'Fast, reliable for daily tasks',
  },
  {
    name = 'claude-sonnet-4',
    display = 'Claude 4 Sonnet (Complex)',
    provider = 'Anthropic',
    limit = 300,
    cost_per_1k = 0.015,
    context_window = 200000,
    strengths = { 'Deep reasoning', 'Complex analysis', 'Long context' },
    best_for = { 'architecture reviews', 'complex debugging', 'detailed analysis' },
    description = 'Superior for complex reasoning and analysis',
  },
  {
    name = 'gpt-3.5-turbo',
    display = 'GPT-3.5 (Fast)',
    provider = 'OpenAI',
    limit = nil,
    cost_per_1k = 0.001,
    context_window = 16000,
    strengths = { 'Very fast', 'Low cost', 'Simple tasks' },
    best_for = { 'simple questions', 'quick fixes', 'basic explanations' },
    description = 'Fastest responses, good for simple tasks',
  },
}

-- State management
local state_file = vim.fn.stdpath 'data' .. '/ai_ultra_model_state.json'

-- Enhanced default state
local default_state = {
  current_model = 'gpt-4.1',
  usage = {},
  preferences = {
    auto_switch = true,
    preferred_daily = 'gpt-4.1',
    preferred_complex = 'claude-sonnet-4',
    preferred_fast = 'gpt-3.5-turbo',
  },
  session_stats = {
    requests_today = 0,
    last_session_date = os.date '%Y-%m-%d',
    total_requests = 0,
  },
}

-- Initialize usage tracking for all models
local function init_usage_for_models(state)
  for _, model in ipairs(M.models) do
    if model.limit and not state.usage[model.name] then
      state.usage[model.name] = {
        count = 0,
        last_reset = os.date '%Y-%m-01',
        daily_count = 0,
        last_daily_reset = os.date '%Y-%m-%d',
      }
    end
  end
  return state
end

-- Safe state loading with migration
function M.load_state()
  if vim.fn.filereadable(state_file) == 1 then
    local content = vim.fn.readfile(state_file)
    if #content > 0 then
      local ok, state = pcall(vim.fn.json_decode, table.concat(content, '\n'))
      if ok and type(state) == 'table' then
        -- Migrate old state format
        state = vim.tbl_deep_extend('force', default_state, state)
        state = init_usage_for_models(state)

        -- Reset daily counts if new day
        local today = os.date '%Y-%m-%d'
        if state.session_stats.last_session_date ~= today then
          state.session_stats.requests_today = 0
          state.session_stats.last_session_date = today

          -- Reset daily counts for all models
          for model_name, usage in pairs(state.usage) do
            if usage.last_daily_reset ~= today then
              usage.daily_count = 0
              usage.last_daily_reset = today
            end
          end
        end

        return state
      end
    end
  end

  local state = vim.deepcopy(default_state)
  return init_usage_for_models(state)
end

-- Enhanced state saving with error handling
function M.save_state(state)
  local ok, content = pcall(vim.fn.json_encode, state)
  if ok then
    local write_ok = pcall(vim.fn.writefile, { content }, state_file)
    if not write_ok then
      vim.notify('Failed to save AI model state to ' .. state_file, vim.log.levels.ERROR)
    end
  else
    vim.notify('Failed to encode AI model state: ' .. content, vim.log.levels.ERROR)
  end
end

-- Get current model with validation
function M.get_current_model()
  local state = M.load_state()
  local current = state.current_model or 'gpt-4.1'

  -- Validate model exists
  for _, model in ipairs(M.models) do
    if model.name == current then
      return current
    end
  end

  -- Fallback to default if current model is invalid
  vim.notify('Invalid current model, falling back to gpt-4.1', vim.log.levels.WARN)
  return 'gpt-4.1'
end

-- Enhanced model switching with validation and usage checks
function M.set_current_model(model_name)
  local state = M.load_state()

  -- Find and validate model
  local target_model = nil
  for _, model in ipairs(M.models) do
    if model.name == model_name then
      target_model = model
      break
    end
  end

  if not target_model then
    vim.notify('Invalid model: ' .. model_name, vim.log.levels.ERROR)
    return false
  end

  -- Check usage limits before switching
  if target_model.limit then
    local usage = state.usage[model_name]
    if usage and usage.count >= target_model.limit then
      vim.notify(
        string.format('Cannot switch to %s: Monthly limit reached (%d/%d)', target_model.display, usage.count, target_model.limit),
        vim.log.levels.WARN
      )
      return false
    end
  end

  -- Update state
  state.current_model = model_name
  M.save_state(state)

  -- Update CopilotChat model if available
  local ok, copilot_chat = pcall(require, 'CopilotChat')
  if ok then
    -- Note: CopilotChat might not have a direct API to change models
    -- This would need to be implemented based on the actual CopilotChat API
    pcall(function()
      copilot_chat.setup { model = model_name }
    end)
  end

  vim.notify(string.format('Switched to %s', target_model.display), vim.log.levels.INFO)
  return true
end

-- Enhanced usage tracking with daily and monthly limits
function M.track_usage(model_name)
  model_name = model_name or M.get_current_model()
  local state = M.load_state()

  -- Find model info
  local model_info = nil
  for _, model in ipairs(M.models) do
    if model.name == model_name then
      model_info = model
      break
    end
  end

  -- Update session stats
  state.session_stats.requests_today = state.session_stats.requests_today + 1
  state.session_stats.total_requests = state.session_stats.total_requests + 1

  -- Track usage for limited models
  if model_info and model_info.limit then
    local usage = state.usage[model_name]
    if not usage then
      usage = {
        count = 0,
        last_reset = os.date '%Y-%m-01',
        daily_count = 0,
        last_daily_reset = os.date '%Y-%m-%d',
      }
      state.usage[model_name] = usage
    end

    -- Check if we need to reset monthly counter
    local current_month = os.date '%Y-%m-01'
    if usage.last_reset ~= current_month then
      usage.count = 0
      usage.last_reset = current_month
    end

    -- Check if we need to reset daily counter
    local today = os.date '%Y-%m-%d'
    if usage.last_daily_reset ~= today then
      usage.daily_count = 0
      usage.last_daily_reset = today
    end

    -- Increment counters
    usage.count = usage.count + 1
    usage.daily_count = usage.daily_count + 1

    -- Check limits and auto-switch if needed
    local limit = model_info.limit
    if usage.count >= limit then
      vim.notify(
        string.format(
          '🚨 %s monthly limit reached! (%d/%d)\nAuto-switching to %s...',
          model_info.display,
          usage.count,
          limit,
          state.preferences.preferred_daily
        ),
        vim.log.levels.WARN
      )
      M.set_current_model(state.preferences.preferred_daily)
    elseif usage.count >= limit * 0.9 then
      vim.notify(
        string.format('⚠️ %s usage at %d%% (%d/%d this month)', model_info.display, math.floor(usage.count / limit * 100), usage.count, limit),
        vim.log.levels.WARN
      )
    elseif usage.daily_count >= 50 then -- Daily soft limit
      vim.notify(string.format('📊 High usage today: %d requests to %s', usage.daily_count, model_info.display), vim.log.levels.INFO)
    end
  end

  M.save_state(state)
end

-- Enhanced usage information with detailed stats
function M.get_usage_info()
  local state = M.load_state()
  local current = M.get_current_model()

  -- Find current model info
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

  local info_parts = { model_info.display }

  if model_info.limit then
    local usage = state.usage[current] or { count = 0, daily_count = 0 }
    local percentage = math.floor(usage.count / model_info.limit * 100)
    table.insert(info_parts, string.format('(%d/%d - %d%%)', usage.count, model_info.limit, percentage))

    if usage.daily_count > 0 then
      table.insert(info_parts, string.format('[%d today]', usage.daily_count))
    end
  else
    table.insert(info_parts, '(Unlimited)')
  end

  return table.concat(info_parts, ' ')
end

-- Comprehensive usage statistics
function M.show_usage_stats()
  local state = M.load_state()
  local lines = {
    '🤖 AI Ultra Model Usage Statistics',
    string.rep('=', 45),
    '',
  }

  -- Current session info
  table.insert(lines, string.format('📊 Session: %d requests today, %d total', state.session_stats.requests_today, state.session_stats.total_requests))
  table.insert(lines, '')

  -- Model usage details
  for _, model in ipairs(M.models) do
    local status_icon = model.name == M.get_current_model() and '🟢' or '⚪'

    if model.limit then
      local usage = state.usage[model.name] or { count = 0, daily_count = 0 }
      local percentage = math.floor(usage.count / model.limit * 100)
      local daily_info = usage.daily_count > 0 and string.format(' (%d today)', usage.daily_count) or ''

      table.insert(lines, string.format('%s %s: %d/%d (%d%%)%s', status_icon, model.display, usage.count, model.limit, percentage, daily_info))

      -- Add usage bar
      local bar_length = 20
      local filled = math.floor(percentage / 100 * bar_length)
      local bar = string.rep('█', filled) .. string.rep('░', bar_length - filled)
      table.insert(lines, string.format('   [%s] %s', bar, percentage >= 90 and '🚨 HIGH' or percentage >= 70 and '⚠️ MEDIUM' or '✅ OK'))
    else
      table.insert(lines, string.format('%s %s: Unlimited', status_icon, model.display))
    end

    -- Model details
    table.insert(lines, string.format('   💰 $%.3f/1k tokens | 🧠 %dk context | %s', model.cost_per_1k, model.context_window / 1000, model.description))
    table.insert(lines, '')
  end

  -- Recommendations
  table.insert(lines, '💡 Recommendations:')
  local current_model = M.get_current_model()
  local current_usage = state.usage[current_model]

  if current_usage and current_usage.count > 200 then
    table.insert(lines, '   • Consider using GPT-3.5 for simple tasks')
  end
  if state.session_stats.requests_today > 30 then
    table.insert(lines, '   • High usage today - consider breaks between requests')
  end

  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end

-- Smart model selection based on task complexity and current usage
function M.suggest_model(task_type, complexity)
  local state = M.load_state()

  local suggestions = {
    simple = 'gpt-3.5-turbo',
    daily = 'gpt-4.1',
    complex = 'claude-sonnet-4',
    analysis = 'claude-sonnet-4',
    debugging = 'claude-sonnet-4',
    explanation = 'gpt-4.1',
    generation = 'gpt-4.1',
  }

  local suggested = suggestions[task_type] or suggestions[complexity] or 'gpt-4.1'

  -- Check if suggested model has capacity
  for _, model in ipairs(M.models) do
    if model.name == suggested and model.limit then
      local usage = state.usage[suggested]
      if usage and usage.count >= model.limit then
        -- Fallback to daily driver
        suggested = state.preferences.preferred_daily
        vim.notify(string.format('%s limit reached, using %s instead', model.display, suggested), vim.log.levels.INFO)
        break
      end
    end
  end

  return suggested
end

-- Auto-switch model based on context and usage
function M.auto_switch_model(context)
  if not context then
    return
  end

  local state = M.load_state()
  if not state.preferences.auto_switch then
    return
  end

  local current = M.get_current_model()
  local suggested = current

  -- Suggest based on context
  if context.has_diagnostics and context.diagnostic_count > 3 then
    suggested = M.suggest_model('debugging', 'complex')
  elseif context.file_size and context.file_size > 10000 then
    suggested = M.suggest_model('analysis', 'complex')
  elseif context.is_test then
    suggested = M.suggest_model('generation', 'daily')
  elseif context.filetype == 'markdown' then
    suggested = M.suggest_model('simple', 'simple')
  end

  -- Switch if suggestion is different and available
  if suggested ~= current then
    local switched = M.set_current_model(suggested)
    if switched then
      vim.notify(string.format('Auto-switched to %s for this task', M.get_model_display_name(suggested)), vim.log.levels.INFO)
    end
  end
end

-- Get model display name
function M.get_model_display_name(model_name)
  for _, model in ipairs(M.models) do
    if model.name == model_name then
      return model.display
    end
  end
  return model_name
end

-- Health check for model system
function M.health_check()
  local state = M.load_state()
  local health = {
    state_file_accessible = vim.fn.filereadable(state_file) == 1,
    current_model_valid = false,
    usage_tracking_active = false,
  }

  -- Check current model validity
  local current = state.current_model
  for _, model in ipairs(M.models) do
    if model.name == current then
      health.current_model_valid = true
      break
    end
  end

  -- Check usage tracking
  health.usage_tracking_active = next(state.usage) ~= nil

  return health
end

function M.setup()
  -- Ensure state file exists and is valid
  local state = M.load_state()
  M.save_state(state)

  vim.notify('AI Ultra Models: Ready', vim.log.levels.DEBUG)
end

return M
