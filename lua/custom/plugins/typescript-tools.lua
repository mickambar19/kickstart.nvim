return {
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      settings = {
        -- Enable auto imports
        complete_function_calls = true,
        include_completions_with_insert_text = true,
        tsserver_file_preferences = {
          includeCompletionsForModuleExports = true,
          includeCompletionsWithSnippetText = true,
          includeAutomaticOptionalChainCompletions = true,
          includeCompletionsWithInsertText = true,
          importModuleSpecifierPreference = 'relative',
          quotePreference = 'auto',
        },
        tsserver_format_options = {
          allowIncompleteCompletions = true,
          allowRenameOfImportPath = true,
        },
        code_lens = 'all',
        code_lens_references = true,
      },
      -- handlers = {
      --   ['textDocument/definition'] = require('typescript-tools.api').handlers.definition,
      --   ['textDocument/references'] = require('typescript-tools.api').handlers.references,
      -- },
    },
    config = function(_, opts)
      require('typescript-tools').setup(opts)
      -- Add these keymaps
      vim.keymap.set('n', '<leader>co', ':TSToolsOrganizeImports<CR>', { desc = '[C]ode [O]rganize imports' })
      vim.keymap.set('n', '<leader>ci', ':TSToolsAddMissingImports<CR>', { desc = '[C]ode add missing [I]mports' })
      vim.keymap.set('n', '<leader>cf', ':TSToolsFixAll<CR>', { desc = '[C]ode [F]ix all' })
    end,
  },
}
