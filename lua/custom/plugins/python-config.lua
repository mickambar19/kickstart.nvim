return {
  {
    'neovim/nvim-lspconfig',
    opts = {},
    config = function(_, opts)
      -- Python-specific settings
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'python',
        callback = function()
          -- Set Python indentation to PEP 8 standards
          vim.bo.tabstop = 4
          vim.bo.softtabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.expandtab = true
          vim.bo.textwidth = 88 -- Black's default line length

          -- Additional Python settings
          local buffer = vim.api.nvim_get_current_buf()
          vim.opt_local.colorcolumn = '88' -- Visual indicator at line length limit

          -- Python-specific keymaps
          -- Run the current Python file
          vim.keymap.set('n', '<leader>pr', ':w<CR>:!python %<CR>', { buffer = buffer, desc = '[P]ython [R]un file' })

          -- Run the current file with arguments
          vim.keymap.set('n', '<leader>pa', function()
            local args = vim.fn.input 'Args: '
            vim.cmd 'w'
            vim.cmd('!python ' .. vim.fn.expand '%' .. ' ' .. args)
          end, { buffer = buffer, desc = '[P]ython run with [A]rguments' })

          -- Open Python REPL
          vim.keymap.set('n', '<leader>ps', ':terminal python<CR>i', { buffer = buffer, desc = '[P]ython [S]hell' })

          -- Execute current line in Python REPL (needs terminal setup)
          vim.keymap.set('n', '<leader>pl', "yy:terminal python -c '<C-r>\"'<CR>", { buffer = buffer, desc = '[P]ython execute [L]ine' })
        end,
      })
    end,
  },
}
