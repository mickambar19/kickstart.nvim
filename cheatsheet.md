# Comprehensive Neovim Keybindings Cheatsheet

> Note: `<leader>` is mapped to the space bar

## Navigation

| Key              | Description                       | Usage Example                                 |
|------------------|-----------------------------------|----------------------------------------------|
| `<C-u>`          | Move half-page up and center      | Reading code? Use `<C-u>` to scroll up smoothly |
| `<C-d>`          | Move half-page down and center    | Reviewing a file? `<C-d>` scrolls down with cursor centered |
| `n`              | Next search result and center     | After searching `/function`, use `n` to go to next match |
| `N`              | Previous search result and center | Too far? Use `N` to go back to previous match |

## File Operations

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>fw`     | Save file                        | Made changes? `<Space>fw` quickly saves your work |
| `<leader>fW`     | Save file without formatting     | Want to save without triggering formatters? Use `<Space>fW` |
| `<leader>ff`     | Format file                      | Code messy? `<Space>ff` formats entire file |

## Buffer Management

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>bn`     | Go to next buffer                | Working with multiple files? `<Space>bn` cycles to next |
| `<leader>bp`     | Go to previous buffer            | Need the previous file? `<Space>bp` goes back |
| `<leader>bd`     | Delete buffer                    | Done with current file? `<Space>bd` closes it |
| `<leader><leader>` | Find existing buffers          | Not sure which buffer you need? `<Space><Space>` shows list |

## Window Management

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>wh`     | Move focus to left window        | Multiple splits open? `<Space>wh` moves left |
| `<leader>wl`     | Move focus to right window       | Need to edit right pane? `<Space>wl` focuses it |
| `<leader>wj`     | Move focus to lower window       | Want the window below? `<Space>wj` jumps down |
| `<leader>wk`     | Move focus to upper window       | Code reference above? `<Space>wk` moves up |
| `<leader>wr`     | Split window right               | Need side-by-side editing? `<Space>wr` splits right |
| `<leader>wd`     | Split window down                | Want to see two sections? `<Space>wd` splits down |
| `<leader>x`      | Close window                     | Done with this split? `<Space>x` closes it |
| `<leader>X`      | Close all windows                | Finished session? `<Space>X` closes everything |
| `<C-w>x`         | Close window but keep buffer     | Keep file open but close view? `<Ctrl>w x` does this |

## Tab Management

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>tn`     | New tab                          | Want separate workspace? `<Space>tn` creates new tab |
| `<leader>tc`     | Close tab                        | Done with this context? `<Space>tc` closes tab |
| `<leader>to`     | Close other tabs                 | Focus only on current tab? `<Space>to` closes others |
| `<leader>gt`     | Go to next tab                   | Working across tabs? `<Space>gt` cycles forward |
| `<leader>gT`     | Go to previous tab               | Need previous context? `<Space>gT` moves back |

## Search/Telescope

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>sh`     | Search help tags                 | Need Neovim docs? `<Space>sh` then type "autocommand" |
| `<leader>sk`     | Search keymaps                   | Forgotten a shortcut? `<Space>sk` then search "format" |
| `<leader>sf`     | Search files                     | Looking for a file? `<Space>sf` then type partial name |
| `<leader>ss`     | Search select telescope          | Explore Telescope options with `<Space>ss` |
| `<leader>sw`     | Search current word              | Find all uses of symbol? Put cursor on it, `<Space>sw` |
| `<leader>sg`     | Search by grep                   | Need to find text? `<Space>sg` then type "function main" |
| `<leader>sd`     | Search diagnostics               | See all warnings/errors with `<Space>sd` |
| `<leader>sr`     | Resume last search               | Continue last search with `<Space>sr` |
| `<leader>s.`     | Search recent files              | Need a recently edited file? `<Space>s.` shows them |
| `<leader>/`      | Fuzzy search in current buffer   | Find text in current file? `<Space>/` then type |
| `<leader>s/`     | Search in open files             | Search only in open buffers with `<Space>s/` |
| `<leader>sn`     | Search neovim config files       | Edit config? `<Space>sn` finds init.lua and others |
| `<leader>sa`     | Search files (including hidden)  | Need to find .gitignore? `<Space>sa` shows hidden files |

## Code Actions

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>ca`     | Code action                      | Fix an error? With cursor on it, `<Space>ca` shows options |
| `<leader>rn`     | Rename symbol                    | Refactoring? `<Space>rn` renames variable everywhere |

## Git Operations

| Key                 | Description                      | Usage Example                                 |
|---------------------|----------------------------------|----------------------------------------------|
| `<leader>gst`       | Git status                       | Check repo status with `<Space>gst` |
| `<leader>gw`        | Git write                        | Save and stage file with `<Space>gw` |
| `<leader>ga`        | Git add current file             | Stage current changes with `<Space>ga` |
| `<leader>gcmsg`     | Git commit with message          | Quick commit? `<Space>gcmsg` prompts for message |
| `<leader>gco`       | Git checkout                     | Switch branches with `<Space>gco` then type branch name |
| `<leader>gcb`       | Git create branch                | New feature? `<Space>gcb` prompts for branch name |
| `<leader>gb`        | Git branch                       | List branches with `<Space>gb` |
| `<leader>gd`        | Git diff                         | See uncommitted changes with `<Space>gd` |
| `<leader>gds`       | Git diff staged                  | Review staged changes before commit with `<Space>gds` |
| `<leader>gdw`       | Git diff word                    | See word-level changes with `<Space>gdw` |
| `<leader>gbl`       | Git blame                        | Who wrote this? `<Space>gbl` shows author for each line |
| `<leader>gbL`       | Git blame line                   | Just blame current line with `<Space>gbL` |
| `<leader>gp`        | Git push                         | Push commits with `<Space>gp` |
| `<leader>gl`        | Git pull                         | Update repo with `<Space>gl` |
| `<leader>glo`       | Git log                          | View commit history with `<Space>glo` |
| `<leader>grb`       | Git rebase                       | Rebase current branch with `<Space>grb main` |
| `<leader>gbr`       | Git browse (GitHub)              | Open current file on GitHub with `<Space>gbr` |

## Git Signs

| Key                 | Description                      | Usage Example                                 |
|---------------------|----------------------------------|----------------------------------------------|
| `]c`                | Jump to next git change          | Navigate through changes with `]c` |
| `[c`                | Jump to previous git change      | Go back to previous change with `[c` |
| `<leader>ggs`       | Stage hunk                       | Stage just this section with `<Space>ggs` |
| `<leader>ggr`       | Reset hunk                       | Discard this change with `<Space>ggr` |
| `<leader>ggS`       | Stage buffer                     | Stage everything in file with `<Space>ggS` |
| `<leader>ggU`       | Unstage buffer                   | Unstage everything in file with `<Space>ggU` |
| `<leader>ggu`       | Undo stage hunk                  | Revert staging of section with `<Space>ggu` |
| `<leader>ggR`       | Reset buffer                     | Discard all changes in file with `<Space>ggR` |
| `<leader>ggp`       | Preview hunk                     | See what changed with `<Space>ggp` |
| `<leader>ggb`       | Blame line                       | Who changed this? `<Space>ggb` shows author |
| `<leader>ggd`       | Diff against index               | Compare with staged version using `<Space>ggd` |
| `<leader>ggD`       | Diff against last commit         | Compare with last commit using `<Space>ggD` |
| `<leader>tb`        | Toggle git show blame line       | Show/hide line blame with `<Space>tb` |
| `<leader>tD`        | Toggle git show deleted          | Show/hide deleted lines with `<Space>tD` |

## LSP Navigation

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `gd`             | Go to definition                 | Where's this function defined? Use `gd` on it |
| `gr`             | Go to references                 | Find all usages of symbol with `gr` |
| `gI`             | Go to implementation             | See interface implementation with `gI` |
| `<leader>D`      | Type definition                  | What type is this? Use `<Space>D` |
| `gD`             | Go to declaration                | Jump to declaration with `gD` |
| `<leader>ds`     | Document symbols                 | Search for symbols in file with `<Space>ds` |
| `<leader>ws`     | Workspace symbols                | Find symbols in project with `<Space>ws` |
| `<C-s>`          | Show signature help (insert)     | Get function signature with `<Ctrl>s` while typing |
| `<leader>ts`     | Toggle signature                 | Show/hide function docs with `<Space>ts` |

## Diagnostics

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>dq`     | Open diagnostic quickfix list    | See all errors/warnings with `<Space>dq` |

## Toggle Options

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>tl`     | Toggle line numbers              | Switch between number modes with `<Space>tl` |
| `<leader>th`     | Toggle inlay hints               | Show/hide type hints with `<Space>th` |

## File Explorer (Neo-tree)

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `\`              | Neo-tree reveal                  | Open file browser with `\` |

## Debug

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>dc`     | Debug continue                   | Start/continue debugging with `<Space>dc` |
| `<leader>di`     | Debug step into                  | Step into function with `<Space>di` |
| `<leader>dn`     | Debug next                       | Execute next line with `<Space>dn` |
| `<leader>do`     | Debug step out                   | Return from function with `<Space>do` |
| `<leader>db`     | Debug breakpoint toggle          | Set/remove breakpoint with `<Space>db` |
| `<leader>dt`     | Debug set text breakpoint        | Conditional breakpoint? `<Space>dt` then enter condition |
| `<leader>dui`    | Debug UI toggle                  | Show/hide debug interface with `<Space>dui` |

## Python Specific

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>pr`     | Run Python file                  | Execute current script with `<Space>pr` |
| `<leader>pv`     | Select Python venv               | Change virtual environment with `<Space>pv` |
| `<leader>pc`     | Create Python venv               | Make new venv with `<Space>pc` |
| `<leader>dt`     | Debug test method                | Test a specific method with `<Space>dt` |
| `<leader>dtc`    | Debug test class                 | Debug a test class with `<Space>dtc` |
| `<leader>ds`     | Debug selection                  | Debug selected code with `<Space>ds` |

## TypeScript

| Key              | Description                      | Usage Example                                 |
|------------------|----------------------------------|----------------------------------------------|
| `<leader>co`     | Organize imports                 | Sort imports with `<Space>co` |
| `<leader>ci`     | Add missing imports              | Fix import errors with `<Space>ci` |
| `<leader>cf`     | Fix all                          | Fix all auto-fixable issues with `<Space>cf` |
| `<leader>ef`     | ESLint fix all                   | Apply all ESLint fixes with `<Space>ef` |

## Mini.nvim Surround Operations

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `saiw)`         | Surround add inner word with parentheses | Put cursor on word, type `saiw)` to get (word) |
| `sd'`           | Surround delete single quotes            | With cursor in 'text', type `sd'` to get text |
| `sr)'`          | Surround replace parentheses with quotes | With cursor in (text), `sr)'` gives 'text' |

## Text Objects (Mini.ai)

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `va)`           | Visually select around parentheses       | Select (text) including parens with `va)` |
| `yinq`          | Yank inside next quote                   | Copy next quoted text with `yinq` |
| `ci'`           | Change inside single quotes              | Replace 'text' content with `ci'` |

## Completion (nvim-cmp)

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `<C-n>`         | Select next completion item              | Navigate down completion menu with `<Ctrl>n` |
| `<C-p>`         | Select previous completion item          | Go up in suggestions with `<Ctrl>p` |
| `<C-b>`         | Scroll docs backward                     | Scroll up in documentation with `<Ctrl>b` |
| `<C-f>`         | Scroll docs forward                      | See more documentation with `<Ctrl>f` |
| `<C-y>`         | Confirm completion                       | Accept suggestion with `<Ctrl>y` |
| `<C-Space>`     | Trigger completion manually              | Force completion menu with `<Ctrl>Space` |
| `<C-l>`         | Expand snippet or jump to next position  | Navigate forward in snippet with `<Ctrl>l` |
| `<C-h>`         | Jump to previous snippet position        | Go back in snippet with `<Ctrl>h` |

## Arrow Key Training

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `<left>`        | Displays "Use h to move!!" message      | Try using arrow keys and get reminded to use h |
| `<right>`       | Displays "Use l to move!!" message      | Helps train you to use l instead of right arrow |
| `<up>`          | Displays "Use k to move!!" message      | Gentle reminder to use k for up movement |
| `<down>`        | Displays "Use j to move!!" message      | Encourages using j instead of down arrow |

## Terminal Keybindings

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `<Esc><Esc>`    | Exit terminal mode                      | Return to normal mode from terminal with double-Esc |

## Other Editing Commands

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `J`              | Join lines (keeps cursor position)      | Merge current line with line below using `J` |
| `J` (visual)     | Move line down                          | Select lines with `V`, then `J` to move down |
| `K` (visual)     | Move line up                            | Select lines with `V`, then `K` to move up |
| `<leader>q`      | Quick quit                              | Exit Neovim quickly with `<Space>q` |
| `<Esc>`          | Clear search highlights                 | Remove search highlighting with `<Esc>` |

## Commands

| Command         | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `:Lazy`         | Open plugin manager                     | Manage plugins with `:Lazy` |
| `:StartupTime`  | Measure Neovim startup time             | Check performance with `:StartupTime` |
| `:checkhealth`  | Run health checks for Neovim            | Troubleshoot with `:checkhealth` |
| `:ConformInfo`  | Show formatter info                     | See available formatters with `:ConformInfo` |
| `:Mason`        | Open Mason package manager              | Install LSP servers with `:Mason` |



