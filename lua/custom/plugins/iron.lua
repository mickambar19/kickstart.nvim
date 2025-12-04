return {
  {
    'Vigemus/iron.nvim',
    config = function()
      local iron = require 'iron.core'

      iron.setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            javascript = {
              command = { 'node' },
            },
            typescript = {
              command = { 'ts-node' },
            },
          },
          repl_open_cmd = require('iron.view').split.vertical.botright(0.4),
        },
        keymaps = {
          send_motion = '<space>sc',
          visual_send = '<space>sc',
          send_file = '<space>sf',
          send_line = '<space>sl',
          send_paragraph = '<space>sp',
          send_until_cursor = '<space>su',
          send_mark = '<space>sm',
          mark_motion = '<space>mc',
          mark_visual = '<space>mc',
          remove_mark = '<space>md',
          cr = '<space>s<cr>',
          interrupt = '<space>s<space>',
          exit = '<space>sq',
          clear = '<space>cl',
        },
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true,
      }

      -- Register which-key groups
      local ok, which_key = pcall(require, 'which-key')
      if ok then
        which_key.add {
          { '<leader>r', group = '[R]EPL' },
          { '<leader>s', group = '[S]end to REPL' },
          { '<leader>e', group = '[E]val' },
        }
      end

      -- Global keymaps for REPL management (work in any buffer)
      vim.keymap.set('n', '<leader>rs', '<cmd>IronRepl<cr>', { desc = '[R]EPL [S]tart' })
      vim.keymap.set('n', '<leader>rr', '<cmd>IronRestart<cr>', { desc = '[R]EPL [R]estart' })
      vim.keymap.set('n', '<leader>rf', '<cmd>IronFocus<cr>', { desc = '[R]EPL [F]ocus' })
      vim.keymap.set('n', '<leader>rh', '<cmd>IronHide<cr>', { desc = '[R]EPL [H]ide' })

      -- Simplified eval keymaps (work immediately after REPL starts)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'python' },
        callback = function(ev)
          local buf = ev.buf

          -- Simple send line (like Conjure's eval)
          vim.keymap.set('n', '<leader>ee', function()
            iron.send_line()
          end, { buffer = buf, desc = '[E]val line' })

          -- Send visual selection
          vim.keymap.set('v', '<leader>ee', function()
            iron.visual_send()
          end, { buffer = buf, desc = '[E]val selection' })

          -- Send entire buffer
          vim.keymap.set('n', '<leader>eb', function()
            iron.send_file()
          end, { buffer = buf, desc = '[E]val buffer' })

          -- Send paragraph (useful for multi-line statements)
          vim.keymap.set('n', '<leader>ep', function()
            iron.send_paragraph()
          end, { buffer = buf, desc = '[E]val paragraph' })

          -- Quick REPL shortcuts
          vim.keymap.set('n', '<leader>rc', '<cmd>IronRepl<cr>', { buffer = buf, desc = '[R]EPL [C]onnect/Start' })
          vim.keymap.set('n', '<leader>rq', '<cmd>IronHide<cr>', { buffer = buf, desc = '[R]EPL [Q]uit/Hide' })
        end,
      })
    end,
  },
}
