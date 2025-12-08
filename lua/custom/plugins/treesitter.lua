return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects', -- Optional but recommended
    },
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    config = function()
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.opt.foldlevelstart = 99 -- Start with all folds open
      vim.opt.foldnestmax = 10 -- Maximum fold depth
      vim.opt.foldminlines = 1 -- Minimum lines to create a fold
      vim.opt.foldcolumn = '1' -- Show fold column (optional)

      -- Configure Treesitter
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'c',
          'diff',
          'html',
          'lua',
          'luadoc',
          'markdown',
          'markdown_inline',
          'query',
          'vim',
          'vimdoc',
          -- Go-related parsers
          'go',
          'gomod',
          'gosum',
          'gowork',
          -- Web development (jsx is handled by javascript and tsx parsers)
          'javascript',
          'typescript',
          'tsx',
          'json',
          'css',
          'scss',
          -- Other languages
          'python',
          'yaml',
          'toml',
          'dockerfile',
          'jinja',
          'terraform',
          'sql',
          'graphql',
          'regex',
          'comment', -- For better comment highlighting
        },

        -- Autoinstall languages that are not installed
        auto_install = true,

        highlight = {
          enable = true,
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          -- If you are experiencing weird indenting issues, add the language to
          -- the list of additional_vim_regex_highlighting and disabled languages for indent.
          additional_vim_regex_highlighting = { 'ruby' },

          -- Disable slow treesitter highlight for large files
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },

        indent = {
          enable = true,
          disable = { 'ruby', 'python' }, -- Python indentation can be problematic
        },

        -- Enable folding
        fold = {
          enable = true,
          disable = {}, -- Don't disable for any languages
        },

        -- Incremental selection based on the named nodes from the grammar
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = '<C-s>',
            node_decremental = '<M-space>',
          },
        },

        -- Textobjects configuration (if you include the textobjects plugin)
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['al'] = '@loop.outer',
              ['il'] = '@loop.inner',
              ['ai'] = '@conditional.outer',
              ['ii'] = '@conditional.inner',
              ['a/'] = '@comment.outer',
              ['i/'] = '@comment.inner',
              ['ab'] = '@block.outer',
              ['ib'] = '@block.inner',
              ['as'] = '@statement.outer',
              ['is'] = '@scopename.inner',
              ['aA'] = '@attribute.outer',
              ['iA'] = '@attribute.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']f'] = '@function.outer',
              [']c'] = '@class.outer',
              [']a'] = '@parameter.inner',
            },
            goto_next_end = {
              [']F'] = '@function.outer',
              [']C'] = '@class.outer',
              [']A'] = '@parameter.inner',
            },
            goto_previous_start = {
              ['[f'] = '@function.outer',
              ['[c'] = '@class.outer',
              ['[a'] = '@parameter.inner',
            },
            goto_previous_end = {
              ['[F'] = '@function.outer',
              ['[C'] = '@class.outer',
              ['[A'] = '@parameter.inner',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>sn'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>sp'] = '@parameter.inner',
            },
          },
        },
      }

      -- Enhanced folding keymaps
      local keymap = vim.keymap.set

      -- Basic fold operations
      keymap('n', '<leader>zf', 'zc', { desc = '[Z]fold [F]old current' })
      keymap('n', '<leader>zu', 'zo', { desc = '[Z]fold [U]nfold current' })
      keymap('n', '<leader>zt', 'za', { desc = '[Z]fold [T]oggle current' })

      -- Level-based folding with feedback
      keymap('n', '<leader>z1', function()
        vim.wo.foldlevel = 1
        vim.notify('Folded to level 1 (overview)', vim.log.levels.INFO)
      end, { desc = '[Z]fold level [1]' })

      keymap('n', '<leader>z2', function()
        vim.wo.foldlevel = 2
        vim.notify('Folded to level 2', vim.log.levels.INFO)
      end, { desc = '[Z]fold level [2]' })

      keymap('n', '<leader>z3', function()
        vim.wo.foldlevel = 3
        vim.notify('Folded to level 3', vim.log.levels.INFO)
      end, { desc = '[Z]fold level [3]' })

      -- Fold all/none
      keymap('n', '<leader>zM', function()
        vim.cmd 'normal! zM'
        vim.notify('Folded all', vim.log.levels.INFO)
      end, { desc = '[Z]fold [M]aximum (all)' })

      keymap('n', '<leader>zR', function()
        vim.cmd 'normal! zR'
        vim.notify('Unfolded all', vim.log.levels.INFO)
      end, { desc = '[Z]fold [R]educe to none' })

      -- Toggle overview mode
      keymap('n', '<leader>zo', function()
        local current_level = vim.wo.foldlevel
        if current_level <= 1 then
          vim.wo.foldlevel = 99
          vim.notify('Expanded to detail view', vim.log.levels.INFO)
        else
          vim.wo.foldlevel = 1
          vim.notify('Collapsed to overview', vim.log.levels.INFO)
        end
      end, { desc = '[Z]fold [O]verview toggle' })

      -- Incremental folding
      keymap('n', '<leader>zm', function()
        vim.cmd 'normal! zm'
        vim.notify('Increased fold level', vim.log.levels.INFO)
      end, { desc = '[Z]fold [m]ore' })

      keymap('n', '<leader>zr', function()
        vim.cmd 'normal! zr'
        vim.notify('Decreased fold level', vim.log.levels.INFO)
      end, { desc = '[Z]fold [r]educe' })

      -- Debug folding
      keymap('n', '<leader>zd', function()
        local fold_info = {
          'Fold Debug Info:',
          'Method: ' .. vim.wo.foldmethod,
          'Expr: ' .. vim.wo.foldexpr,
          'Level: ' .. vim.wo.foldlevel,
          'Start: ' .. vim.wo.foldlevelstart,
          'Column: ' .. vim.wo.foldcolumn,
          'Min lines: ' .. vim.wo.foldminlines,
        }

        -- Check if treesitter folding is working
        local ts_fold = vim.treesitter.foldexpr()
        table.insert(fold_info, 'TS fold expr: ' .. tostring(ts_fold))

        vim.notify(table.concat(fold_info, '\n'), vim.log.levels.INFO)
      end, { desc = '[Z]fold [D]ebug info' })

      -- Visual feedback for folding
      vim.api.nvim_create_autocmd('OptionSet', {
        pattern = 'foldlevel',
        callback = function()
          local level = vim.wo.foldlevel
          if level == 0 then
            vim.notify('All folds closed', vim.log.levels.INFO)
          elseif level >= 99 then
            vim.notify('All folds open', vim.log.levels.INFO)
          end
        end,
        desc = 'Fold level change notification',
      })

      local ok, which_key = pcall(require, 'which-key')
      if ok then
        which_key.add {
          { '<leader>z', group = '[Z]fold operations', mode = { 'n' } },
        }
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      enable = true,
      max_lines = 3,
      min_window_height = 20,
      multiline_threshold = 1,
      trim_scope = 'outer',
    },
    keys = {
      {
        '<leader>tC',
        function()
          require('treesitter-context').toggle()
        end,
        desc = '[T]oggle [C]ontext (sticky scroll)',
      },
    },
  },
}
