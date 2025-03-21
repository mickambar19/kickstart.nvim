return {
  {
    'mfussenegger/nvim-dap-python',
    dependencies = {
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
    },
    ft = { 'python' },
    config = function()
      -- Configure Python debugging
      local path = require('mason-registry').get_package('debugpy'):get_install_path()
      require('dap-python').setup(path .. '/venv/bin/python')

      -- Add configurations for different Python debugging scenarios
      -- Add Python test configurations
      require('dap-python').test_runner = 'pytest'

      -- Keymaps specific to Python debugging
      -- Match the Go debugging keybindings style
      vim.keymap.set('n', '<leader>db', require('dap').toggle_breakpoint, { desc = '[D]ebug [B]reakpoint Toggle' })
      vim.keymap.set('n', '<leader>dc', require('dap').continue, { desc = '[D]ebug [C]ontinue' })
      vim.keymap.set('n', '<leader>dd', require('dap').clear_breakpoints, { desc = '[D]ebug [D]elete Breakpoints' })
      vim.keymap.set('n', '<leader>dui', require('dapui').toggle, { desc = '[D]ebug [UI] Toggle' })

      -- Improved stepping controls
      vim.keymap.set('n', '<leader>dn', require('dap').step_over, { desc = '[D]ebug [N]ext' })
      vim.keymap.set('n', '<leader>di', require('dap').step_into, { desc = '[D]ebug step [I]nto' })
      vim.keymap.set('n', '<leader>do', require('dap').step_out, { desc = '[D]ebug step [O]ut' })

      -- Python-specific test debugging (similar to Go's debug_test)
      vim.keymap.set('n', '<leader>dt', function()
        require('dap-python').test_method()
      end, { desc = '[D]ebug [T]est method' })

      vim.keymap.set('n', '<leader>dtc', function()
        require('dap-python').test_class()
      end, { desc = '[D]ebug [T]est [C]lass' })

      vim.keymap.set('n', '<leader>ds', function()
        require('dap-python').debug_selection()
      end, { desc = '[D]ebug [S]election' })
    end,
  },
}
