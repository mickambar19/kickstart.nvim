# Git Workflow & Debugging Guide

> **Essential for**: Version control mastery and efficient debugging

## 🔀 Git Integration Workflow

### Quick Git Status & Operations
| Action | Key | What It Shows |
|--------|-----|---------------|
| **Git status** | `<Space>gst` | Modified files, staging status |
| **Git add current** | `<Space>ga` | Stage current file |
| **Quick commit** | `<Space>gcmsg` | Commit with message prompt |
| **Git push** | `<Space>gp` | Push commits to remote |
| **Git pull** | `<Space>gl` | Pull latest changes |

### Branch Management
| Action | Key | Perfect For |
|--------|-----|-------------|
| **Switch branch** | `<Space>gco` | Checkout existing branch |
| **Create branch** | `<Space>gcb` | Create and switch to new branch |
| **List branches** | `<Space>gb` | See all local branches |
| **Git browse** | `<Space>gbr` | Open file on GitHub |

### Advanced Git Operations
| Action | Key | When You Need It |
|--------|-----|-----------------|
| **Git diff** | `<Space>gd` | See uncommitted changes |
| **Git diff staged** | `<Space>gds` | Review staged changes |
| **Git diff word** | `<Space>gdw` | Word-level change view |
| **Git blame** | `<Space>gbl` | Who wrote each line |
| **Git blame line** | `<Space>gbL` | Blame just current line |
| **Git log** | `<Space>glo` | Commit history |
| **Git rebase** | `<Space>grb` | Rebase current branch |

## 🔍 GitSigns - Inline Git Info

### Hunk Navigation
| Action | Key | What It Does |
|--------|-----|--------------|
| **Next change** | `]c` | Jump to next git change |
| **Previous change** | `[c` | Jump to previous git change |
| **Preview hunk** | `<Space>ggp` | See what changed |
| **Stage hunk** | `<Space>ggs` | Stage just this section |
| **Reset hunk** | `<Space>ggr` | Discard this change |

### Advanced Hunk Operations
| Action | Key | Use Case |
|--------|-----|----------|
| **Stage buffer** | `<Space>ggS` | Stage entire file |
| **Unstage buffer** | `<Space>ggU` | Unstage entire file |
| **Reset buffer** | `<Space>ggR` | Discard all changes in file |
| **Blame line** | `<Space>ggb` | See who changed this line |
| **Diff vs index** | `<Space>ggd` | Compare with staged version |
| **Diff vs commit** | `<Space>ggD` | Compare with last commit |

### Git Display Toggles
| Action | Key | Visual Effect |
|--------|-----|---------------|
| **Toggle blame** | `<Space>tb` | Show/hide line blame |
| **Toggle deleted** | `<Space>tD` | Show/hide deleted lines |

## 🐛 Debugging with DAP

### Basic Debugging
| Action | Key | What It Does |
|--------|-----|--------------|
| **Start/Continue** | `<Space>dc` | Begin debugging or continue execution |
| **Step into** | `<Space>di` | Step into function calls |
| **Step over** | `<Space>dn` | Execute next line |
| **Step out** | `<Space>do` | Return from current function |
| **Toggle breakpoint** | `<Space>db` | Set/remove breakpoint |
| **Conditional breakpoint** | `<Space>dt` | Breakpoint with condition |
| **Debug UI** | `<Space>dui` | Show/hide debug interface |

### Language-Specific Debugging

#### Python Debugging
| Action | Key | Perfect For |
|--------|-----|-------------|
| **Debug test method** | `<Space>dt` | Debug specific test |
| **Debug test class** | `<Space>dtc` | Debug entire test class |
| **Debug selection** | `<Space>ds` | Debug selected code |

#### Go Debugging
- Automatic setup for Go projects
- Debug single files or entire packages
- Table test debugging support

## 📊 Diagnostics & Error Management

### Error Navigation
| Action | Key | When to Use |
|--------|-----|-------------|
| **Open diagnostic** | `<Space>dd` | See error details in float |
| **Diagnostic list** | `<Space>dl` | All errors in quickfix |
| **All diagnostics** | `<Space>sd` | Search all project errors |

### Quick Error Fixes
| Action | Key | What It Fixes |
|--------|-----|---------------|
| **Code actions** | `<Space>ca` | Auto-import, quick fixes |
| **Rename symbol** | `<Space>rn` | Rename everywhere safely |
| **Format file** | `<Space>ff` | Fix formatting issues |

## 🚀 Complete Git Workflows

### Daily Development Workflow
```bash
# 1. Start new feature
<Space>gcb → Create feature branch

# 2. Make changes and check status
<Space>gst → See what's modified

# 3. Review changes before staging
<Space>gd → See diff of changes
]c → Jump through individual changes
<Space>ggp → Preview each hunk

# 4. Stage selectively
<Space>ggs → Stage good hunks
<Space>ggr → Reset problematic hunks

# 5. AI-powered commit
<Space>aga → AI generates commit message

# 6. Push changes
<Space>gp → Push to remote
```

### Code Review Workflow
```bash
# 1. Review staged changes
<Space>gds → See what will be committed

# 2. Get AI review
<Space>agr → AI reviews your changes

# 3. Check blame for context
<Space>gbl → See who wrote surrounding code

# 4. Browse on GitHub
<Space>gbr → Open file on GitHub for context
```

### Bug Investigation Workflow
```bash
# 1. Find problematic commit
<Space>glo → Look at recent commits
<Space>gbl → Blame lines around bug

# 2. See what changed
<Space>gd → Current changes
<Space>ggD → Compare with last known good commit

# 3. Debug the issue
<Space>db → Set breakpoint
<Space>dc → Start debugging
<Space>di → Step through code
```

### Merge Conflict Resolution
```bash
# 1. See conflicted files
<Space>gst → Git status shows conflicts

# 2. Navigate conflict markers
]c → Jump between conflict sections

# 3. Choose resolution
<Space>ggs → Stage resolved sections
<Space>ggr → Reset and try different approach

# 4. Complete merge
<Space>gcmsg → Commit merge resolution
```

## 🔧 Advanced Debugging Techniques

### Conditional Debugging
```bash
# Set conditional breakpoint
<Space>dt → "user_id == 123"
# Only breaks when condition is true
```

### Debug Configuration
The setup includes configurations for:
- **Go**: Single files, test files, and packages
- **Python**: Scripts, pytest, and selected code
- **JavaScript/TypeScript**: Node.js and browser debugging

### Debug UI Layout
```
┌─────────────────┬─────────────────┐
│     Variables   │                 │
│     Breakpoints │   Code Editor   │
│     Call Stack  │                 │
│     Watches     │                 │
├─────────────────┼─────────────────┤
│     REPL        │    Console      │
│                 │                 │
└─────────────────┴─────────────────┘
```

## 💡 Pro Tips

### Git Integration
- **Smart blame**: AI can explain why code was written
- **Custom git commands**: Use `<Space>agd` for AI-powered diff analysis
- **GitHub integration**: `<Space>gbr` opens current file on GitHub

### Debugging Best Practices
```bash
# Set breakpoints before running
<Space>db → Set strategic breakpoints

# Use conditional breakpoints for loops
<Space>dt → "i > 100" (for performance debugging)

# Debug tests to understand failures
<Space>dt → Debug failing test method
```

### Combining Git + AI
```bash
# Before committing:
<Space>agr → AI reviews changes
<Space>aga → AI generates commit message
<Space>gp → Push with confidence

# For investigation:
<Space>gbl → See who wrote code
<Space>ae → AI explains the code's purpose
```

### Custom Git Workflows
```bash
# Quick status check
<Space>gst

# Stage and commit in one flow
<Space>ga → <Space>gcmsg → <Space>gp

# Review before push
<Space>gds → <Space>agr → <Space>gp
```

---

## 🎯 Common Scenarios

### "I broke something" Recovery
```bash
1. <Space>gst → See what changed
2. <Space>ggr → Reset bad hunks
3. <Space>gd → Verify fixes
4. <Space>dc → Debug remaining issues
```

### "What did this commit do?"
```bash
1. <Space>glo → Find the commit
2. <Space>gbl → Blame the lines
3. <Space>ae → AI explains the code
```

### "Need to debug failing test"
```bash
1. <Space>dt → Debug test method
2. <Space>di → Step through test
3. <Space>db → Set breakpoints in implementation
4. <Space>dc → Continue debugging
```

> **Master these workflows** and you'll handle any development scenario with confidence. Git and debugging become powerful allies rather than obstacles.
