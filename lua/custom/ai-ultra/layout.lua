-- ... existing CopilotChat setup code ...
local M = {}

local chat_layout = 'float' -- Default layout state

-- Function to toggle between float and vertical layouts
local function toggle_chat_layout()
  local chat = require 'CopilotChat'

  if chat_layout == 'float' then
    -- Switch to vertical (right side)
    chat_layout = 'vertical'
    chat.open {
      window = {
        layout = 'vertical',
        width = 0.4, -- 40% of screen width
        relative = 'editor',
        border = 'rounded',
        title = ' AI Assistant (Side Panel) ',
      },
    }
    vim.notify('Chat: Side Panel Mode', vim.log.levels.INFO)
  else
    -- Switch to float (modal)
    chat_layout = 'float'
    chat.open {
      window = {
        layout = 'float',
        width = 0.85,
        height = 0.85,
        relative = 'editor',
        border = 'rounded',
        row = 1,
        col = 1,
        title = ' AI Assistant (Modal) ',
        title_pos = 'center',
      },
    }
    vim.notify('Chat: Modal Mode', vim.log.levels.INFO)
  end
end

-- Function to quickly jump between chat and source
local function quick_jump_to_source()
  local chat = require 'CopilotChat'
  local source = chat.get_source()

  if source and source.winnr and vim.api.nvim_win_is_valid(source.winnr) then
    vim.api.nvim_set_current_win(source.winnr)
  else
    vim.notify('No source window found', vim.log.levels.WARN)
  end
end

local function quick_jump_to_chat()
  local chat = require 'CopilotChat'
  if chat.chat and chat.chat:visible() then
    chat.chat:focus()
  else
    -- Open chat in current layout mode
    if chat_layout == 'float' then
      vim.cmd 'CopilotChatToggle'
    else
      toggle_chat_layout() -- This will open in vertical mode
    end
  end
end

function M.setup_layout()
  -- Set up autocommands for chat-specific keybindings
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'copilot-chat',
    callback = function(ev)
      local opts = { buffer = ev.buf, silent = true }

      -- Quick navigation from chat to source
      vim.keymap.set('n', '<C-w>s', quick_jump_to_source, vim.tbl_extend('force', opts, { desc = 'Jump to source file' }))

      -- Toggle layout while in chat
      vim.keymap.set('n', '<C-w>t', toggle_chat_layout, vim.tbl_extend('force', opts, { desc = 'Toggle chat layout' }))

      -- Quick apply and jump to source
      vim.keymap.set('n', '<C-w>a', function()
        -- Accept any pending diff first
        vim.cmd 'normal! <C-y>'
        vim.defer_fn(quick_jump_to_source, 100)
      end, vim.tbl_extend('force', opts, { desc = 'Apply changes and jump to source' }))
    end,
  })

  -- Global keybindings for chat management
  vim.keymap.set('n', '<leader>al', toggle_chat_layout, { desc = '[A]I [L]ayout toggle' })
  vim.keymap.set('n', '<leader>ajj', quick_jump_to_chat, { desc = '[A]I [J]ump to chat' })
  vim.keymap.set('n', '<leader>ajs', quick_jump_to_source, { desc = '[A]I jump to [S]ource' })

  -- Enhanced chat toggle that respects current layout (MODIFY EXISTING <leader>aa)
  vim.keymap.set('n', '<leader>aa', function()
    local chat = require 'CopilotChat'
    if chat.chat and chat.chat:visible() then
      chat.close()
    else
      if chat_layout == 'float' then
        vim.cmd 'CopilotChatToggle'
      else
        toggle_chat_layout()
      end
    end
  end, { desc = '[A]I [A]ctivate chat (smart)' })
end

return M
