return function(_, bufnr)
  local keymap = vim.keymap.set

  keymap('n', '<leader>pr', ':w<CR>:!python %<CR>', { buffer = bufnr, desc = '[P]ython [R]un file' })
end
