-- lua/custom/plugins/python-venv.lua
return {
  {
    'AckslD/swenv.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ft = 'python',
    config = function()
      require('swenv').setup {
        venvs_path = vim.fn.expand '~/.virtualenvs',
        venv_patterns = {
          '.venv',
          'venv',
          'env',
          '.env',
        },
        post_set_venv = function()
          vim.cmd 'LspRestart'
        end,
      }

      -- Keymaps
      vim.keymap.set('n', '<leader>pv', function()
        require('swenv.api').pick_venv()
      end, { desc = '[P]ython select [V]env' })

      vim.keymap.set('n', '<leader>pc', function()
        local name = vim.fn.input 'Venv name: '
        if name and name ~= '' then
          require('swenv.api').create_venv(name)
        end
      end, { desc = '[P]ython [C]reate venv' })

      -- Store the venv info globally for statusline access
      _G.python_venv_info = function()
        if vim.bo.filetype ~= 'python' then
          return ''
        end

        local swenv = require 'swenv.api'
        local venv = swenv.get_current_venv()

        if venv and venv.name then
          -- Extract Python version from venv name (e.g., "py3.13" from poetry venv)
          local version = venv.name:match 'py(%d+%.%d+)'
          if version then
            return ' 🐍' .. version
          end
          -- If no version pattern, show just an icon
          return ' 🐍'
        end

        -- Fallback to VIRTUAL_ENV
        local env_path = os.getenv 'VIRTUAL_ENV'
        if env_path then
          local venv_name = vim.fn.fnamemodify(env_path, ':t')
          local version = venv_name:match 'py(%d+%.%d+)'
          if version then
            return ' 🐍' .. version
          end
          return ' 🐍'
        end

        return ''
      end
    end,
  },
}
