return {
  {
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-rhubarb', -- for GBrowse
    },
    cmd = {
      'G',
      'Git',
      'Gdiffsplit',
      'Gread',
      'Gwrite',
      'Ggrep',
      'GMove',
      'GDelete',
      'GBrowse',
    },
    keys = {
      -- Main commands
      { '<leader>gst', '<cmd>tab Git<cr>', desc = '[G]it [St]atus' },
      { '<leader>gw', '<cmd>Gwrite<cr>', desc = '[G]it [W]rite' },

      -- Commit workflow
      { '<leader>ga', '<cmd>Git add %<cr>', desc = '[G]it [A]dd' },
      {
        '<leader>gcmsg',
        function()
          local msg = vim.fn.input 'Commit message > '
          if msg ~= '' then
            vim.cmd('Git commit -m "' .. msg .. '"')
          end
        end,
        desc = '[G]it [C]ommit [M]e[s]sa[g]e',
      },

      -- Branch operations
      {
        '<leader>gco',
        function()
          vim.cmd('Git checkout ' .. vim.fn.input 'Branch > ')
        end,
        desc = '[G]it Check[o]ut',
      },
      {
        '<leader>gcb',
        function()
          local branch = vim.fn.input 'New branch > '
          if branch ~= '' then
            vim.cmd('Git checkout -b ' .. branch)
          end
        end,
        desc = '[G]it [C]reate [B]ranch',
      },
      { '<leader>gb', '<cmd>Git branch<cr>', desc = '[G]it [B]ranch' },

      -- Diff commands
      { '<leader>gd', '<cmd>Git diff<cr>', desc = '[G]it [D]iff' },
      { '<leader>gds', '<cmd>Git diff --staged<cr>', desc = '[G]it [D]iff [S]taged' },
      { '<leader>gdw', '<cmd>Git diff --word-diff<cr>', desc = '[G]it [D]iff [W]ord' },

      -- Blame commands
      { '<leader>gbl', '<cmd>Git blame<cr>', desc = '[G]it [Bl]ame' },
      {
        '<leader>gbL',
        function()
          local line = vim.fn.line '.'
          vim.cmd('Git blame -L ' .. line .. ',' .. line)
        end,
        desc = '[G]it [B]lame [L]ine',
      },

      -- Pull/Push
      { '<leader>gp', '<cmd>Git push<cr>', desc = '[G]it [P]ush' },
      { '<leader>gl', '<cmd>Git pull<cr>', desc = '[G]it Pu[l]l' },

      -- Log
      { '<leader>glo', '<cmd>Git log<cr>', desc = '[G]it [Lo]g' },

      -- Rebase
      {
        '<leader>grb',
        function()
          vim.cmd('Git rebase ' .. vim.fn.input 'Rebase onto > ')
        end,
        desc = '[G]it [R]e[b]ase',
      },

      -- Browse (GitHub)
      { '<leader>gbr', '<cmd>GBrowse<cr>', desc = '[G]it [Br]owse' },
    },
  },
}
