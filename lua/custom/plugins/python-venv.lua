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
        -- Enable automatic activation
        post_set_venv = function()
          -- Refresh LSP servers to use new Python environment
          vim.cmd 'LspRestart'
        end,
      }

      -- Keymaps to manage virtual environments
      vim.keymap.set('n', '<leader>pv', function()
        require('swenv.api').pick_venv()
      end, { desc = '[P]ython select [V]env' })

      vim.keymap.set('n', '<leader>pc', function()
        local name = vim.fn.input 'Venv name: '
        if name and name ~= '' then
          require('swenv.api').create_venv(name)
        end
      end, { desc = '[P]ython [C]reate venv' })
    end,
  },

  -- Display Python venv info in your statusline (optional)
  {
    'echasnovski/mini.statusline',
    optional = true, -- Only applies if mini.statusline is used
    config = function()
      -- Override statusline to include Python venv info
      local statusline = require 'mini.statusline'
      local orig_section_mode = statusline.section_mode

      statusline.section_mode = function()
        local result = orig_section_mode()
        -- If using Python, try to show virtual env info
        if vim.bo.filetype == 'python' then
          local venv = os.getenv 'VIRTUAL_ENV'
          if venv then
            local venv_name = vim.fn.fnamemodify(venv, ':t')
            result = result .. ' [' .. venv_name .. ']'
          end
        end
        return result
      end
    end,
  },
}
