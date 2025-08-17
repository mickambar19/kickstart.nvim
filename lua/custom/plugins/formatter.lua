return {
  {
    -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>ff',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ile [F]ormat',
      },
      {
        '<leader>fp',
        function()
          local conform = require 'conform'

          -- Get current buffer info
          local bufnr = vim.api.nvim_get_current_buf()
          local filetype = vim.bo[bufnr].filetype

          -- Check if filetype supports prettier
          local prettier_filetypes = {
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
            'json',
            'jsonc',
            'html',
            'css',
            'scss',
            'less',
            'yaml',
            'markdown',
          }

          local supports_prettier = false
          for _, ft in ipairs(prettier_filetypes) do
            if filetype == ft then
              supports_prettier = true
              break
            end
          end

          if not supports_prettier then
            vim.notify("Prettier doesn't support filetype: " .. filetype, vim.log.levels.WARN)
            return
          end

          -- Check if prettier is available
          if vim.fn.executable 'prettier' == 0 then
            vim.notify('Prettier not found. Install with: npm install -g prettier', vim.log.levels.ERROR)
            return
          end

          -- THIS IS THE KEY PART - Use 'prettier_force' not 'prettier'
          conform.format({
            bufnr = bufnr,
            formatters = { 'prettier_force' }, -- ← This tells it to use your force formatter
            async = true,
            lsp_format = 'never',
          }, function(err)
            if err then
              vim.notify('Force prettier formatting failed: ' .. err, vim.log.levels.ERROR)
            else
              vim.notify('Formatted with prettier (default config)', vim.log.levels.INFO)
            end
          end)
        end,
        desc = '[F]ormat with [P]rettier (force)',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 2500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- You can use 'stop_after_first' to run the first available formatter from the list
        html = { 'prettierd', 'prettier', stop_after_first = true },
        javascript = { 'prettier', stop_after_first = true },
        typescript = { 'prettier', stop_after_first = true },
        javascriptreact = { 'prettier', stop_after_first = true },
        typescriptreact = { 'prettier', stop_after_first = true },
        json = { 'prettier' },
        jsonc = { 'prettier' },
        terraform = { 'terraform_fmt' }, -- Install terraform cli not only the lsp
        python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
        bash = { 'shfmt' },
        sh = { 'shfmt' },
        go = { 'goimports', 'gofumpt' },
        yaml = { 'yamlfmt' },
        ['yaml.ansible'] = { 'yamlfmt' },
      },
      formatters = {
        yamlfmt = {
          command = 'yamlfmt',
          args = { '-in' },
          stdin = true,
          condition = function(_, ctx)
            return vim.fn.executable 'yamlfmt' == 1
          end,
        },

        ansible_lint = {
          command = 'ansible-lint',
          args = { '--fix', '-' },
          stdin = true,
          condition = function(_, ctx)
            -- Check if file is in an Ansible project
            local ansible_files = {
              'ansible.cfg',
              'playbook.yml',
              'playbooks/',
              'roles/',
              'inventory/',
              'group_vars/',
              'host_vars/',
            }

            for _, file in ipairs(ansible_files) do
              if require('conform.util').root_file { file }(_, ctx) then
                return true
              end
            end

            -- Also check if filename suggests it's Ansible
            local filename = vim.fn.fnamemodify(ctx.filename, ':t')
            return filename:match 'playbook' or filename:match 'main%.ya?ml' or filename:match 'tasks%.ya?ml'
          end,
        },

        prettier = {
          -- Only run prettier when config file exists
          condition = function(_, ctx)
            local filetype = vim.bo[ctx.buf].filetype

            if filetype:match 'yaml' or filetype == 'ansible' then
              return true
            end
            -- Check for dedicated prettier config files
            local byPrettierConfigFile = require('conform.util').root_file {
              '.prettierrc',
              '.prettierrc.json',
              '.prettierrc.yml',
              '.prettierrc.yaml',
              '.prettierrc.json5',
              '.prettierrc.js',
              '.prettierrc.cjs',
              '.prettierrc.mjs',
              '.prettierrc.toml',
              'prettier.config.js',
              'prettier.config.cjs',
              'prettier.config.mjs',
            }(_, ctx)

            if byPrettierConfigFile then
              return true
            end

            -- Check for prettier config in package.json (first level only)
            local package_json_root = require('conform.util').root_file { 'package.json' }(_, ctx)
            if package_json_root then
              local package_json_path = package_json_root .. '/package.json'
              local ok, content = pcall(vim.fn.readfile, package_json_path)
              if ok then
                local json_str = table.concat(content, '\n')
                -- Parse JSON and check for top-level prettier key
                local json_ok, json_data = pcall(vim.fn.json_decode, json_str)
                if json_ok and json_data and json_data.prettier then
                  return true
                end
              end
            end

            return false
          end,
          command = function(_, ctx)
            local project_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
            if vim.v.shell_error == 0 and project_root ~= '' then
              local prettier_path = project_root .. '/node_modules/.bin/prettier'
              if vim.fn.filereadable(prettier_path) == 1 then
                return prettier_path
              end
            end
            return 'prettier' -- fallback to global
          end,
        },
        shfmt = {
          prepend_args = { '-i', '2', '-ci' }, -- 2-space indent, indent switch cases
        },
        jq = {
          -- Optional: Configure jq arguments
          args = { '--indent', '2' },
        },
        prettier_force = {
          command = function(_, ctx)
            local project_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
            if vim.v.shell_error == 0 and project_root ~= '' then
              local prettier_path = project_root .. '/node_modules/.bin/prettier'
              if vim.fn.filereadable(prettier_path) == 1 then
                return prettier_path
              end
            end
            return 'prettier' -- fallback to global
          end,
          args = {
            '--stdin-filepath',
            '$FILENAME',
            -- Default configuration
            '--tab-width',
            '2',
            '--use-tabs',
            'false',
            '--single-quote',
            'true',
            '--trailing-comma',
            'es5',
            '--bracket-spacing',
            'true',
            '--prose-wrap',
            'preserve',
            '--semi',
            'false',
          },
          stdin = true,
        },
      },
    },
  },
}
