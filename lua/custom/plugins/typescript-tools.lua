return {
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }, -- Lazy load only for JS/TS files
    opts = {
      -- Performance optimizations
      single_file_support = false, -- Disable for better performance in projects

      settings = {
        -- Faster completions
        separate_diagnostic_server = true, -- Use separate server for diagnostics
        publish_diagnostic_on = 'insert_leave', -- Less frequent diagnostic updates

        -- Optimized file preferences
        tsserver_file_preferences = {
          -- Core completion settings
          includeCompletionsForModuleExports = true,
          includeCompletionsWithSnippetText = false, -- Disable for speed
          includeAutomaticOptionalChainCompletions = false, -- Can be slow
          includeCompletionsWithInsertText = true,

          -- Import preferences
          importModuleSpecifierPreference = 'relative',
          importModuleSpecifierEnding = 'minimal',
          quotePreference = 'single',

          -- Performance improvements
          allowIncompleteCompletions = true, -- More accurate but slower
          allowRenameOfImportPath = true,
          allowTextChangesInNewFiles = true,

          -- Disable expensive features
          providePrefixAndSuffixTextForRename = false,
          includePackageJsonAutoImports = 'off', -- Can be very slow

          -- File size limits
          maxFileSize = 4194304, -- 4MB limit
        },

        -- Optimized server options
        tsserver_format_options = {
          -- Reduce formatting overhead
          allowIncompleteCompletions = false,
          allowRenameOfImportPath = false,
        },

        -- Disable expensive features for better performance
        code_lens = 'off', -- Major performance impact

        -- Workspace configuration
        tsserver_max_memory = 8192, -- Increase memory limit

        -- Exclude large directories from watching
        exclude_dirs = {
          'node_modules',
          '.git',
          'dist',
          'build',
          'coverage',
          '.next',
          '.nuxt',
          '.output',
          '.vite',
        },
      },

      -- Enhanced root detection for better performance
      root_dir = function(fname)
        local util = require 'lspconfig.util'
        return util.root_pattern('tsconfig.json', 'jsconfig.json')(fname) or util.root_pattern 'package.json'(fname) or util.find_git_ancestor(fname)
      end,

      -- Optimize initialization
      init_options = {
        preferences = {
          -- Faster completions
          disableSuggestions = false,
          quotePreference = 'single',
          includeCompletionsForModuleExports = true,
          includeCompletionsWithSnippetText = false,
          includeAutomaticOptionalChainCompletions = false,
          includeCompletionsForImportStatements = true,
          allowIncompleteCompletions = false,
        },
        -- Performance settings
        maxTsServerMemory = 8192,
        locale = 'en',
        -- Disable telemetry for slight performance gain
        disableAutomaticTypingAcquisition = true,
      },
    },

    config = function(_, opts)
      require('typescript-tools').setup(opts)

      -- Optimized keymaps
      local keymap = vim.keymap.set
      keymap('n', '<leader>co', ':TSToolsOrganizeImports<CR>', { desc = '[C]ode [O]rganize imports' })
      keymap('n', '<leader>ci', ':TSToolsAddMissingImports<CR>', { desc = '[C]ode add missing [I]mports' })
      keymap('n', '<leader>cf', ':TSToolsFixAll<CR>', { desc = '[C]ode [F]ix all' })
      keymap('n', '<leader>cR', ':TSToolsFileReferences<CR>', { desc = '[C]ode [R]eferences' })
      keymap('n', '<leader>cD', ':TSToolsGoToSourceDefinition<CR>', { desc = '[C]ode [D]efinition (source)' })
      keymap('n', '<leader>crf', ':TSToolsRenameFile<CR>', { desc = '[C]ode [R]ename [F]ile' })

      -- Code lens toggle with safe keymap
      keymap('n', '<leader>cl', function()
        local current_buf = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients { bufnr = current_buf, name = 'typescript-tools' }

        if #clients == 0 then
          vim.notify('TypeScript LSP not active in this buffer', vim.log.levels.WARN)
          return
        end

        local client = clients[1]
        local current_setting = client.config.settings.code_lens or 'off'

        -- Toggle between 'off' and 'all'
        local new_setting = current_setting == 'off' and 'all' or 'off'

        -- Update the client configuration
        client.config.settings.code_lens = new_setting
        client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })

        -- Clear existing code lens
        vim.lsp.codelens.clear(client.id, current_buf)

        -- Refresh if enabled
        if new_setting == 'all' then
          vim.defer_fn(function()
            vim.lsp.codelens.refresh()
          end, 100)
          vim.notify('Code lens enabled', vim.log.levels.INFO)
        else
          vim.notify('Code lens disabled', vim.log.levels.INFO)
        end
      end, { desc = '[C]ode [L]ens toggle' })

      -- Alternative: More granular code lens controls
      keymap('n', '<leader>cla', function()
        local current_buf = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients { bufnr = current_buf, name = 'typescript-tools' }
        if #clients > 0 then
          clients[1].config.settings.code_lens = 'all'
          clients[1].notify('workspace/didChangeConfiguration', { settings = clients[1].config.settings })
          vim.lsp.codelens.refresh()
          vim.notify('Code lens: All enabled', vim.log.levels.INFO)
        end
      end, { desc = '[C]ode [L]ens [A]ll' })

      keymap('n', '<leader>clr', function()
        local current_buf = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients { bufnr = current_buf, name = 'typescript-tools' }
        if #clients > 0 then
          clients[1].config.settings.code_lens = 'references'
          clients[1].notify('workspace/didChangeConfiguration', { settings = clients[1].config.settings })
          vim.lsp.codelens.refresh()
          vim.notify('Code lens: References only', vim.log.levels.INFO)
        end
      end, { desc = '[C]ode [L]ens [R]eferences only' })

      keymap('n', '<leader>clo', function()
        local current_buf = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients { bufnr = current_buf, name = 'typescript-tools' }
        if #clients > 0 then
          clients[1].config.settings.code_lens = 'off'
          clients[1].notify('workspace/didChangeConfiguration', { settings = clients[1].config.settings })
          vim.lsp.codelens.clear(clients[1].id, current_buf)
          vim.notify('Code lens: Disabled', vim.log.levels.INFO)
        end
      end, { desc = '[C]ode [L]ens [O]ff' })

      -- Performance-focused autocmds
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
        callback = function(args)
          local bufnr = args.buf

          -- Set up buffer-local settings
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
          vim.opt_local.expandtab = true

          -- Skip large files
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if ok and stats and stats.size > max_filesize then
            vim.notify('Large TypeScript file detected, some features disabled for performance', vim.log.levels.WARN)
            -- Disable expensive features for large files
            vim.b[bufnr].large_file = true
            return
          end
        end,
      })

      -- Memory cleanup
      vim.api.nvim_create_autocmd('BufDelete', {
        pattern = { '*.ts', '*.tsx', '*.js', '*.jsx' },
        callback = function()
          -- Force garbage collection when closing TS files
          collectgarbage 'collect'
        end,
      })
    end,
  },
}
