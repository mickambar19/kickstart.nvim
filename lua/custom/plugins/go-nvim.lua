return {
  {
    'ray-x/go.nvim',
    dependencies = {
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('go').setup {
        lsp_cfg = {
          settings = {
            gopls = {

              analyses = {
                unusedparams = true,
                shadow = true,
                nilness = true,
                unusedwrite = true,
                useany = true,
              },
              staticcheck = true,
              gofumpt = true,
              usePlaceholders = true,
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },

        -- Format on save
        lsp_document_formatting = true,

        -- Set up diagnostics with reduced features
        lsp_inlay_hints = {
          enable = true,
          -- Set to a higher number to reduce updates
          only_current_line = false,
          only_current_line_autocmd = 'CursorHold',
          show_variable_name = true,
          show_parameter_hints = true,
          parameter_hints_prefix = ' <- ',
          other_hints_prefix = ' => ',
          max_len_align = false,
          max_len_align_padding = 1,
          right_align = false,
          right_align_padding = 6,
          highlight = 'Comment',
        },

        -- Use faster formatter
        formatter = 'gofmt', -- Changed from 'gofumpt' to 'gofmt' for speed

        -- Auto-formatting on save with file size limit
        lsp_on_attach = function(client, bufnr)
          local format_sync_grp = vim.api.nvim_create_augroup('goimports', {})
          vim.api.nvim_create_autocmd('BufWritePre', {
            pattern = '*.go',
            callback = function()
              -- Skip formatting for large files
              local max_file_size = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
              if ok and stats and stats.size < max_file_size then
                require('go.format').goimports()
              end
            end,
            group = format_sync_grp,
          })
        end,

        -- Reduce background processes
        run_in_floaterm = false,
      }
      -- Configure Go file-specific settings
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'go',
        callback = function()
          -- Set tab width to 4 spaces for Go files
          vim.bo.tabstop = 2
          vim.bo.shiftwidth = 4
          vim.bo.expandtab = false -- Go uses tabs, not spaces
          vim.opt_local.listchars = {
            tab = '▎ ',
            extends = '›',
            precedes = '‹',
            trail = '·',
          }
        end,
      })
    end,
    -- Only load for Go files when they're actually opened
    ft = { 'go', 'gomod' },
    -- Remove CmdlineEnter which might load the plugin too early
    -- event = { 'CmdlineEnter' },
    build = ':lua require("go.install").update_all_sync()',
  },
}
