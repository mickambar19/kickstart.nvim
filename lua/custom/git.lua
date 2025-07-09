-- lua/custom/git.lua
local M = {}

function M.open_pr_from_blame()
  local line_num = vim.fn.line '.'
  local file_path = vim.fn.expand '%'

  -- Get commit hash from blame first
  local blame_output = vim.fn.system(string.format('git blame -L %d,%d %s', line_num, line_num, file_path))

  if vim.v.shell_error ~= 0 then
    print 'Error getting git blame information'
    return
  end

  -- Extract commit hash (first field in blame output)
  local commit_hash = blame_output:match '^([a-f0-9]+)'

  if not commit_hash then
    print 'Could not extract commit hash from blame'
    return
  end

  -- Get the full commit message
  local commit_msg = vim.fn.system(string.format('git log --format=%%s -n 1 %s', commit_hash))

  if vim.v.shell_error ~= 0 then
    print 'Error getting commit message'
    return
  end

  -- Debug: show what we're searching in
  print('Commit message: ' .. commit_msg:gsub('\n', ''))

  -- Look for PR number in various formats
  local pr_number = commit_msg:match '#(%d+)'
    or commit_msg:match '%(#(%d+)%)' -- (PR #123)
    or commit_msg:match 'PR[%s]*#?(%d+)' -- PR 123 or PR#123
    or commit_msg:match 'pull[%s]+request[%s]*#?(%d+)' -- pull request 123

  if not pr_number then
    print('No PR number found in commit message: ' .. commit_msg:gsub('\n', ''))
    print 'Searched patterns: #123, (#123), PR 123, PR#123, pull request 123'
    return
  end

  local remote_url = vim.fn.system('git config --get remote.origin.url'):gsub('\n', '')

  if vim.v.shell_error ~= 0 then
    print 'Error getting remote URL'
    return
  end

  remote_url = remote_url:gsub('git@github%.com:', 'https://github.com/')
  remote_url = remote_url:gsub('%.git$', '')

  local pr_url = remote_url .. '/pull/' .. pr_number

  local open_cmd
  if vim.fn.has 'mac' == 1 then
    open_cmd = 'open'
  elseif vim.fn.has 'unix' == 1 then
    open_cmd = 'xdg-open'
  elseif vim.fn.has 'win32' == 1 then
    open_cmd = 'start'
  else
    print 'Unsupported platform'
    return
  end

  vim.fn.system(open_cmd .. ' "' .. pr_url .. '"')
  print('Opening PR #' .. pr_number .. ': ' .. pr_url)
end

function M.open_pr_by_number()
  local pr_num = vim.fn.input 'PR number: #'
  if pr_num ~= '' then
    local remote_url = vim.fn.system('git config --get remote.origin.url'):gsub('\n', ''):gsub('%.git$', ''):gsub('git@github%.com:', 'https://github.com/')
    local pr_url = remote_url .. '/pull/' .. pr_num
    local open_cmd = vim.fn.has 'mac' == 1 and 'open' or vim.fn.has 'unix' == 1 and 'xdg-open' or 'start'
    vim.fn.system(open_cmd .. ' "' .. pr_url .. '"')
    print('Opening PR #' .. pr_num)
  end
end

function M.copy_github_url()
  local file_path = vim.fn.expand '%'
  local line_num = vim.fn.line '.'
  local remote_url = vim.fn.system('git config --get remote.origin.url'):gsub('\n', ''):gsub('%.git$', ''):gsub('git@github%.com:', 'https://github.com/')
  local branch = vim.fn.system('git branch --show-current'):gsub('\n', '')
  local github_url = remote_url .. '/blob/' .. branch .. '/' .. file_path .. '#L' .. line_num

  vim.fn.setreg('+', github_url)
  print('Copied to clipboard: ' .. github_url)
end

-- Debug function to see blame output
function M.debug_blame()
  local line_num = vim.fn.line '.'
  local file_path = vim.fn.expand '%'

  print '=== Debug Blame Info ==='
  print('File: ' .. file_path)
  print('Line: ' .. line_num)

  -- Standard blame
  local blame_output = vim.fn.system(string.format('git blame -L %d,%d %s', line_num, line_num, file_path))
  print('Blame output: ' .. blame_output:gsub('\n', ''))

  -- Get commit hash
  local commit_hash = blame_output:match '^([a-f0-9]+)'
  print('Commit hash: ' .. (commit_hash or 'NOT FOUND'))

  if commit_hash then
    -- Get commit message
    local commit_msg = vim.fn.system(string.format('git log --format=%%s -n 1 %s', commit_hash))
    print('Commit message: ' .. commit_msg:gsub('\n', ''))

    -- Get full commit info
    local commit_full = vim.fn.system(string.format('git log --format="%%s%%n%%b" -n 1 %s', commit_hash))
    print('Full commit: ' .. commit_full:gsub('\n', ' | '))
  end

  print '=== End Debug ==='
end

return M
