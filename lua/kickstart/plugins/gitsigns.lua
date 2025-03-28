-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      signs_staged = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mod
        map('v', '<leader>ggs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[G]it [G]it [s]tage hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[G]it [G]it [r]eset hunk' })
        -- normal mode
        map('n', '<leader>ggs', gitsigns.stage_hunk, { desc = '[G]it [G]it [s]tage hunk' })
        map('n', '<leader>ggr', gitsigns.reset_hunk, { desc = '[G]it [G]it [r]eset hunk' })
        map('n', '<leader>ggS', gitsigns.stage_buffer, { desc = '[G]it [G]it [S]tage buffer' })
        map('n', '<leader>ggU', gitsigns.stage_buffer, { desc = '[G]it [G]it [U]nstage buffer' })
        map('n', '<leader>ggu', gitsigns.stage_hunk, { desc = '[G]it [G]it [u]ndo stage hunk' })
        map('n', '<leader>ggR', gitsigns.reset_buffer, { desc = '[G]it [G]it [R]eset buffer' })
        map('n', '<leader>ggp', gitsigns.preview_hunk, { desc = '[G]it [G]it [p]review hunk' })
        map('n', '<leader>ggb', gitsigns.blame_line, { desc = '[G]it [G]it [b]lame line' })
        map('n', '<leader>ggd', gitsigns.diffthis, { desc = '[G]it [G]it [d]iff against index' })
        map('n', '<leader>ggD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
      end,
    },
  },
}
