-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    local npairs = require 'nvim-autopairs'

    npairs.setup {
      check_ts = true,
      ts_config = {
        lua = { 'string' }, -- Don't add pairs in lua string treesitter nodes
        javascript = { 'template_string' },
        java = false, -- Don't check treesitter on java
      },
      disable_filetype = { 'TelescopePrompt', 'vim' },
      disable_in_macro = true, -- Disable when recording macros
      disable_in_visualblock = false,
      disable_in_replace_mode = true,
      ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
      enable_moveright = true,
      enable_afterquote = true,
      enable_check_bracket_line = false, -- Don't add pairs if it already has a close pair in the line
      enable_bracket_in_quote = true,
      enable_abbr = false, -- Trigger abbreviation
      break_undo = true, -- Switch for basic rule break undo sequence
      check_comma = true,
      map_cr = true, -- Map Enter key
      map_bs = true, -- Map the <BS> key
      map_c_h = false, -- Don't map <C-h>
      map_c_w = false, -- Don't map <c-w>
    }

    -- Don't interfere with Tab - it's reserved for Copilot
    -- The default autopairs doesn't map Tab anyway, but this ensures it
  end,
}
