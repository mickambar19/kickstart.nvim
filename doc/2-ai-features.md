# Advanced AI Features - Power User Guide

> **Prerequisite**: Familiar with basic commands from the main cheatsheet

## 🧠 AI Model Management

| Action | Key | When to Use |
|--------|-----|-------------|
| **Model menu** | `<Space>ama` | Switch between AI models |
| **Daily model** | `<Space>amd` | Switch to GPT-4.1 (fast, daily tasks) |
| **Complex model** | `<Space>amc` | Switch to Claude 4 (complex analysis) |
| **Fast model** | `<Space>amf` | Switch to GPT-3.5 (quick questions) |
| **Usage stats** | `<Space>amu` | Check AI usage and limits |

### Model Selection Strategy
```
📊 GPT-4.1 (Daily Driver)
└── Perfect for: Quick fixes, explanations, daily coding

🧠 Claude 4 Sonnet (Complex Tasks) 
└── Perfect for: Architecture reviews, complex debugging

⚡ GPT-3.5 (Speed)
└── Perfect for: Simple questions, basic explanations
```

## 🎯 Advanced AI Categories

### Git Integration (`<Space>ag*`)
| Action | Key | What It Does |
|--------|-----|-------------|
| **Smart commit** | `<Space>aga` | AI generates conventional commit messages |
| **Review diff** | `<Space>agr` | AI reviews your changes before commit |
| **Analyze diff** | `<Space>agd` | Deep analysis for bugs/breaking changes |
| **Log analysis** | `<Space>agl` | AI analyzes commit history patterns |

### Code Creation (`<Space>ac*`)
| Action | Key | Perfect For |
|--------|-----|-------------|
| **React component** | `<Space>acr` | Generate new React components |
| **Custom hook** | `<Space>ach` | Extract logic into reusable hooks |
| **Next.js page** | `<Space>acp` | Create new Next.js pages |
| **API route** | `<Space>aca` | Generate Next.js API endpoints |
| **TypeScript interface** | `<Space>aci` | Extract and create TS interfaces |
| **Test suite** | `<Space>act` | Generate comprehensive tests |

### Code Analysis (`<Space>as*`)
| Action | Key | What It Finds |
|--------|-----|---------------|
| **Full analysis** | `<Space>asa` | All issues (bugs, performance, security) |
| **Performance scan** | `<Space>asp` | Memory leaks, slow algorithms, bundle size |
| **Security audit** | `<Space>ass` | XSS, injection, auth flaws (OWASP Top 10) |
| **Accessibility** | `<Space>asw` | WCAG 2.1 compliance issues |
| **TODO scanner** | `<Space>ast` | Find and implement TODOs/FIXMEs |

### Workspace Context (`<Space>aw*`)
| Action | Key | Includes |
|--------|-----|----------|
| **Context help** | `<Space>awc` | Project-aware explanations |
| **Project analysis** | `<Space>awp` | Architecture and structure review |
| **Review changes** | `<Space>awr` | AI reviews in project context |
| **Testing strategy** | `<Space>awt` | Project-wide testing recommendations |

## 🔧 AI-Powered Workflows

### Pre-Commit Workflow
```bash
# 1. Review your changes with AI
<Space>agr

# 2. Fix any issues found
<Space>af (on problematic code)

# 3. Generate smart commit message
<Space>aga

# 4. Commit with AI-generated message
# (AI will prompt you to accept/edit)
```

### Code Review Preparation
```bash
# 1. Full codebase analysis
<Space>asa

# 2. Security audit
<Space>ass

# 3. Performance check
<Space>asp

# 4. Generate tests for new code
<Space>act

# 5. Review final changes
<Space>agr
```

### Debugging Complex Issues
```bash
# 1. Select problematic code
# 2. Get AI explanation
<Space>ae

# 3. If still unclear, ask custom question
<Space>ak → "Why is this function causing memory leaks?"

# 4. Get comprehensive fix
<Space>af

# 5. Generate tests to prevent regression
<Space>at
```

## 🛠️ Advanced AI Commands

### Interactive AI (`<Space>ai`)
Smart context menu that adapts to your current situation:

- **In test file**: "Improve test coverage", "Add test cases"
- **React component**: "Optimize re-renders", "Extract hook" 
- **Has errors**: "Fix diagnostics" appears at top
- **In function**: "Refactor function: functionName"
- **Config file**: "Validate configuration"

### AI Command Palette (`<Space>ap`)
Quick access to all AI features with search:
- Type to filter commands
- Includes git operations, model switching, analysis tools
- Context-aware suggestions

### Smart Suggestions (`<Space>ab`)
AI analyzes current context and suggests relevant actions:
- **TypeScript**: "Add TypeScript types", "Optimize bundle size"
- **React**: "Optimize re-renders", "Extract custom hook"
- **Python**: "Add type hints", "Improve error handling"
- **Go**: "Add error handling", "Optimize goroutines"

## 🧪 Advanced AI Use Cases

### Refactoring Legacy Code
```bash
# 1. Select large function/class
# 2. Get AI analysis
<Space>ar

# 3. Request refactoring
<Space>ax

# 4. Generate tests for new structure
<Space>at

# 5. Performance comparison
<Space>ao
```

### Learning New Frameworks
```bash
# 1. When you see unfamiliar code
<Space>ae → AI explains patterns and concepts

# 2. For project-wide understanding
<Space>awp → AI analyzes entire project structure

# 3. Get implementation examples
<Space>ak → "Show me how to implement authentication in this Next.js app"
```

### API Design and Documentation
```bash
# 1. Create API endpoint
<Space>aca

# 2. Add comprehensive documentation
<Space>ad

# 3. Generate integration tests
<Space>act

# 4. Security review
<Space>ass
```

## 💡 AI Power Tips

### Context Matters
- **Select relevant code** before using AI commands
- Use workspace commands (`<Space>aw*`) for project-wide understanding
- AI remembers your project context across sessions

### Model Switching Strategy
```bash
Quick questions → <Space>amf (GPT-3.5)
Daily coding → <Space>amd (GPT-4.1)  
Complex analysis → <Space>amc (Claude 4)
```

### Combining AI Actions
```bash
# Typical workflow:
<Space>ae → <Space>ar → <Space>af → <Space>at
(Explain → Review → Fix → Test)
```

### Git Integration Workflow
```bash
# Before committing:
<Space>agd → Review changes for issues
<Space>aga → Generate commit message
# AI handles conventional commit format automatically
```

## 🚀 Pro Workflows

### Feature Development Cycle
```bash
1. <Space>awp → Understand project architecture
2. <Space>ac* → Generate new components/APIs
3. <Space>ae → Understand existing integration points
4. <Space>ar → Review implementation
5. <Space>act → Generate comprehensive tests
6. <Space>aga → Smart commit with conventional format
```

### Bug Investigation
```bash
1. <Space>sg → Search for error patterns
2. <Space>ae → Understand problematic code
3. <Space>asp → Check for performance issues
4. <Space>ass → Security implications
5. <Space>af → Get comprehensive fix
6. <Space>at → Generate regression tests
```

### Code Quality Improvement
```bash
1. <Space>asa → Full analysis of file/project
2. <Space>ax → Refactor for maintainability
3. <Space>ao → Performance optimizations
4. <Space>asw → Accessibility improvements
5. <Space>act → Comprehensive test coverage
```

---

## 🎓 Advanced Tips & Tricks

### Context Selection Priority
AI automatically selects the best context:
1. **Visual selection** (if active)
2. **Current error** (if on line with diagnostic)
3. **Function/class** (using treesitter)
4. **Logical block** (based on indentation)
5. **Current line** (fallback)

### Model Auto-Switching
AI automatically suggests better models for complex tasks:
- Switches to Claude for architectural analysis
- Uses GPT-4.1 for daily coding tasks
- Suggests fast model for simple questions

### Workspace Intelligence
AI understands your project:
- Framework detection (React, Next.js, Django, etc.)
- Project structure analysis
- Recent git changes
- Testing strategies
- Dependency management

> **Next Level**: Master these advanced features to become an AI-assisted development expert. The AI becomes your pair programming partner, code reviewer, and architecture consultant all in one.

