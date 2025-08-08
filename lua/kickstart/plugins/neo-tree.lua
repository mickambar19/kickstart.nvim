-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['yy'] = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' then
              -- Copy directory path to system clipboard and create copy command
              local path = node:get_id()
              vim.fn.setreg('+', 'cp -r "' .. path .. '" ')
              vim.notify('Copy command ready in clipboard: cp -r "' .. vim.fn.fnamemodify(path, ':t') .. '"')
            else
              -- Copy file path to clipboard
              local path = node:get_id()
              vim.fn.setreg('+', 'cp "' .. path .. '" ')
              vim.notify('Copy command ready in clipboard: cp "' .. vim.fn.fnamemodify(path, ':t') .. '"')
            end
          end,
          ['pp'] = function(state)
            local node = state.tree:get_node()
            local current_dir

            if node.type == 'directory' then
              current_dir = node:get_id()
            else
              current_dir = vim.fn.fnamemodify(node:get_id(), ':h')
            end

            local clipboard = vim.fn.getreg '+'
            if clipboard:match '^cp ' then
              local cmd = clipboard .. '"' .. current_dir .. '/"'
              vim.fn.system(cmd)
              vim.notify('Pasted to: ' .. current_dir)
              -- Refresh neo-tree
              require('neo-tree.sources.manager').refresh 'filesystem'
            else
              vim.notify 'No valid copy command in clipboard'
            end
          end,
          ['gy'] = function(state)
            -- Copy full path to clipboard
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg('+', path)
            vim.notify('Copied path: ' .. path)
          end,
        },
      },
    },
  },
}
