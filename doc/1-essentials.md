## Basic Movement & Text Objects

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `w`              | Move to beginning of next word          | Navigate word by word with `w` |
| `b`              | Move to beginning of previous word      | Go back word by word with `b` |
| `e`              | Move to end of current word             | Jump to word end with `e` |
| `0`              | Move to beginning of line               | Go to line start with `0` |
| `$`              | Move to end of line                     | Jump to line end with `$` |
| `gg`             | Go to first line of file                | Jump to file beginning with `gg` |
| `G`              | Go to last line of file                 | Jump to file end with `G` |
| `%`              | Jump to matching bracket/paren         | Find matching brace with `%` |
| `f<char>`        | Find character forward on line         | Find next 'a' with `fa` |
| `F<char>`        | Find character backward on line        | Find previous 'a' with `Fa` |
| `t<char>`        | Move to before character forward       | Move before next 'a' with `ta` |
| `T<char>`        | Move to after character backward       | Move after previous 'a' with `Ta` |
```

### 2. **Copy/Paste/Delete Operations**
```markdown
## Copy, Paste & Delete

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `yy`             | Yank (copy) current line                | Copy entire line with `yy` |
| `y$`             | Yank from cursor to end of line        | Copy to line end with `y$` |
| `yiw`            | Yank inner word                         | Copy word under cursor with `yiw` |
| `p`              | Paste after cursor                      | Paste clipboard content with `p` |
| `P`              | Paste before cursor                     | Paste before current position with `P` |
| `dd`             | Delete current line                     | Remove entire line with `dd` |
| `d$`             | Delete from cursor to end of line      | Delete to line end with `d$` |
| `diw`            | Delete inner word                       | Delete word under cursor with `diw` |
| `x`              | Delete character under cursor           | Remove single character with `x` |
| `X`              | Delete character before cursor          | Remove character to left with `X` |
```

### 3. **Insert Mode Commands**
```markdown
## Insert Mode

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `i`              | Insert before cursor                    | Start typing at cursor with `i` |
| `I`              | Insert at beginning of line             | Start typing at line start with `I` |
| `a`              | Insert after cursor                     | Start typing after cursor with `a` |
| `A`              | Insert at end of line                   | Start typing at line end with `A` |
| `o`              | Open new line below                     | Create line below and insert with `o` |
| `O`              | Open new line above                     | Create line above and insert with `O` |
| `s`              | Substitute character                    | Replace character and insert with `s` |
| `S`              | Substitute line                         | Replace entire line with `S` |
```

### 4. **Visual Mode Operations**
```markdown
## Visual Mode

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `v`              | Start visual mode                       | Select characters with `v` |
| `V`              | Start visual line mode                  | Select entire lines with `V` |
| `<C-v>`          | Start visual block mode                 | Select rectangular blocks with `<Ctrl>v` |
| `gv`             | Reselect last visual selection          | Re-select previous selection with `gv` |
| `>`              | Indent selection                        | Indent selected lines with `>` |
| `<`              | Unindent selection                      | Reduce indentation with `<` |
| `=`              | Auto-indent selection                   | Fix indentation with `=` |
```

### 5. **Search and Replace**
```markdown
## Search & Replace

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `/pattern`       | Search forward                          | Find "function" with `/function` |
| `?pattern`       | Search backward                         | Search backwards with `?pattern` |
| `*`              | Search for word under cursor forward    | Find current word with `*` |
| `#`              | Search for word under cursor backward   | Find current word backwards with `#` |
| `:s/old/new/`    | Replace first occurrence in line       | Replace "foo" with "bar": `:s/foo/bar/` |
| `:s/old/new/g`   | Replace all occurrences in line        | Replace all in line: `:s/foo/bar/g` |
| `:%s/old/new/g`  | Replace all in file                     | Replace all in file: `:%s/foo/bar/g` |
| `:%s/old/new/gc` | Replace all with confirmation           | Confirm each replacement: `:%s/foo/bar/gc` |
```

### 6. **Marks and Jumps**
```markdown
## Marks & Jumps

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `m<letter>`      | Set mark                                | Set mark 'a' with `ma` |
| `'<letter>`      | Jump to mark                            | Jump to mark 'a' with `'a` |
| `''`             | Jump to previous position               | Return to last position with `''` |
| `<C-o>`          | Jump to older position                  | Go back in jump list with `<Ctrl>o` |
| `<C-i>`          | Jump to newer position                  | Go forward in jump list with `<Ctrl>i` |
```

### 7. **Macros**
```markdown
## Macros

| Key              | Description                             | Usage Example                                 |
|------------------|-----------------------------------------|----------------------------------------------|
| `q<letter>`      | Start recording macro                   | Record macro 'a' with `qa` |
| `q`              | Stop recording macro                    | Stop recording with `q` |
| `@<letter>`      | Play macro                              | Execute macro 'a' with `@a` |
| `@@`             | Repeat last macro                       | Repeat last executed macro with `@@` |
