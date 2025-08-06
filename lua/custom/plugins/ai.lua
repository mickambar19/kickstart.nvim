return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = '[[',
            jump_next = ']]',
            accept = '<CR>',
            refresh = 'gr',
            open = '<M-p>',
          },
          layout = {
            position = 'right',
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          debounce = 75,
          keymap = {
            accept = '<C-j>',
            accept_word = '<M-w>',
            accept_line = '<M-l>',
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-]>',
          },
        },
        filetypes = {
          yaml = true,
          markdown = true,
          help = false,
          gitcommit = true,
          gitrebase = true,
          ['.'] = false,
          ['avante'] = false, -- Disable in Avante buffers
        },
        copilot_model = 'gpt-4.1-2025-04-14',
      }

      -- Enhanced suggestion styling
      vim.api.nvim_set_hl(0, 'CopilotSuggestion', {
        fg = '#6B7280',
        italic = true,
        blend = 20,
      })

      -- Toggle functionality
      vim.keymap.set('n', '<leader>tc', function()
        require('copilot.suggestion').toggle_auto_trigger()
        local enabled = require('copilot.suggestion').is_visible()
        vim.notify('Copilot ' .. (enabled and 'enabled' or 'disabled'), vim.log.levels.INFO)
      end, { desc = '[T]oggle [C]opilot suggestions' })
    end,
  },
  {
    'yetone/avante.nvim',
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = 'make',
    event = 'VeryLazy',
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      -- add any opts here
      -- for example
      provider = 'copilot',
      auto_suggestions_enabled = false, -- enable auto suggestions
      providers = {
        copilot = {

          endpoint = 'https://api.githubcopilot.com',
          -- model = 'claude-sonnet-4',
          model = 'gpt-4.1-2025-04-14',
          proxy = nil, -- [protocol://]host[:port] Use this proxy
          allow_insecure = false, -- Allow insecure server connections
          timeout = 30000, -- Timeout in milliseconds
          context_window = 64000, -- Number of tokens to send to the model for context
          extra_request_body = {
            temperature = 0.5,
            max_tokens = 20480,
          },
        },
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'echasnovski/mini.pick', -- for file_selector provider mini.pick
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      'ibhagwan/fzf-lua', -- for file_selector provider fzf
      'stevearc/dressing.nvim', -- for input provider dressing
      'folke/snacks.nvim', -- for input provider snacks
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },
}
