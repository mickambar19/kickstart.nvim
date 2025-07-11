local M = {}

-- Base prompts that can be enhanced with context
M.base_prompts = {
  fix = {
    text = 'Fix the issues in this code. Be concise and focus on the actual problem.',
    system = 'You are an expert developer. Provide minimal, working fixes.',
  },

  explain = {
    text = 'Explain this code clearly and concisely. Focus on what it does and why.',
    system = 'You are a patient teacher. Explain complex concepts simply.',
  },

  optimize = {
    text = 'Optimize this code for performance and readability. Explain key improvements.',
    system = 'You are a performance expert. Focus on meaningful optimizations.',
  },

  review = {
    text = 'Review this code for bugs, security issues, and best practices.',
    system = 'You are a senior code reviewer. Be thorough but constructive.',
  },

  tests = {
    text = 'Generate comprehensive tests including edge cases and error scenarios.',
    system = 'You are a testing expert. Write clear, maintainable tests.',
  },

  docs = {
    text = 'Add clear, concise documentation. Include JSDoc/TSDoc where appropriate.',
    system = 'You are a technical writer. Write clear, helpful documentation.',
  },

  refactor = {
    text = 'Refactor this code for better maintainability and clarity.',
    system = 'You are a refactoring expert. Preserve functionality while improving structure.',
  },

  security = {
    text = 'Analyze for security vulnerabilities and suggest fixes.',
    system = 'You are a security expert. Focus on OWASP top 10 and common vulnerabilities.',
  },

  types = {
    text = 'Add or improve TypeScript types. Make them as specific as possible.',
    system = 'You are a TypeScript expert. Write precise, useful types.',
  },
}

-- Framework-specific enhancements
M.framework_prompts = {
  react = {
    fix = 'Fix React-specific issues including hooks dependencies, re-renders, and state management.',
    optimize = 'Optimize for React performance: memoization, lazy loading, code splitting.',
    review = 'Review for React best practices: hooks rules, component patterns, performance.',
    tests = 'Generate React Testing Library tests with user interaction scenarios.',
    types = 'Add React TypeScript types including props, events, and hooks.',
  },

  nextjs = {
    fix = 'Fix Next.js issues including SSR/SSG, routing, and data fetching.',
    optimize = 'Optimize for Next.js: ISR, image optimization, bundle size, Core Web Vitals.',
    review = 'Review for Next.js best practices: rendering strategies, API routes, middleware.',
    tests = 'Generate tests for Next.js pages, API routes, and SSR/SSG logic.',
    types = 'Add Next.js TypeScript types including page props, API handlers, and config.',
  },

  express = {
    fix = 'Fix Express.js issues including middleware, routing, and error handling.',
    optimize = 'Optimize Express performance: caching, compression, database queries.',
    review = 'Review for Express best practices: security, error handling, validation.',
    tests = 'Generate Express tests including integration tests and API endpoint tests.',
  },
}

-- Test-specific prompts
M.test_prompts = {
  fix = 'Fix the failing test. Ensure it properly tests the intended behavior.',
  explain = 'Explain what this test is verifying and why it might be failing.',
  improve = 'Improve this test: better assertions, edge cases, test isolation.',
  generate = 'Generate additional test cases for better coverage.',
}

-- Get enhanced prompt based on context
function M.get_prompt(action, context)
  local base = M.base_prompts[action]
  if not base then
    return nil
  end

  local prompt = vim.deepcopy(base)

  -- Enhance for test files
  if context.is_test and M.test_prompts[action] then
    prompt.text = M.test_prompts[action]
  end

  -- Enhance for specific frameworks
  if context.framework and M.framework_prompts[context.framework] and M.framework_prompts[context.framework][action] then
    prompt.text = M.framework_prompts[context.framework][action]
  end

  -- Add file context
  prompt.text = prompt.text .. string.format('\n\nFile: %s (%s)', context.filename, context.filetype)

  if context.framework then
    prompt.text = prompt.text .. '\nFramework: ' .. context.framework
  end

  return prompt
end

-- Get system prompt based on context
function M.get_system_prompt(context)
  local system = 'You are an expert developer'

  -- Add language expertise
  local lang_map = {
    typescript = 'TypeScript',
    typescriptreact = 'TypeScript and React',
    javascript = 'JavaScript',
    javascriptreact = 'JavaScript and React',
    go = 'Go',
    python = 'Python',
    lua = 'Lua and Neovim',
  }

  if lang_map[context.filetype] then
    system = system .. ' specializing in ' .. lang_map[context.filetype]
  end

  -- Add framework expertise
  if context.framework then
    system = system .. ' with deep ' .. context.framework .. ' knowledge'
  end

  system = system .. '. Provide concise, practical solutions following best practices.'

  return system
end

-- Quick prompts for common tasks
M.quick_prompts = {
  -- React/Next.js specific
  component = 'Create a reusable React component with TypeScript props',
  hook = 'Create a custom React hook with proper TypeScript types',
  nextpage = 'Create a Next.js page component with proper types',
  nextapi = 'Create a Next.js API route with error handling',

  -- General
  todo = 'Find all TODOs and suggest implementations',
  error = 'Explain this error and provide a fix',
  perf = 'Analyze performance bottlenecks and suggest improvements',
  a11y = 'Review accessibility and suggest improvements',

  -- TypeScript
  interface = 'Extract and create proper TypeScript interfaces',
  generics = 'Improve types using generics where appropriate',
  strict = 'Make types stricter and more precise',
}

-- Git commit message templates
M.commit_templates = {
  feat = 'feat: concise description of the new feature',
  fix = 'fix: concise description of the bug fix',
  refactor = 'refactor: concise description of code changes',
  test = 'test: concise description of test changes',
  docs = 'docs: concise description of documentation changes',
  style = 'style: concise description of formatting changes',
  perf = 'perf: concise description of performance improvements',
  chore = 'chore: concise description of maintenance tasks',
}

return M
