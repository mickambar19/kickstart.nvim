local M = {}

function M.get_project_context()
  local context = {
    root = vim.fn.getcwd(),
    git_root = '',
    project_type = 'unknown',
    framework = nil,
    language = 'unknown',
    config_files = {},
    dependencies = {},
    recent_changes = {},
    modified_files = {},
    structure = {},
    package_info = {},
  }

  -- Enhanced git root detection
  local git_root_cmd = vim.fn.system 'git rev-parse --show-toplevel 2>/dev/null'
  if vim.v.shell_error == 0 then
    context.git_root = git_root_cmd:gsub('\n', '')
  else
    context.git_root = context.root
  end

  -- Project type detection with enhanced patterns
  context = M.detect_project_type(context)
  context = M.detect_framework(context)
  context = M.analyze_dependencies(context)
  context = M.get_git_information(context)
  context = M.analyze_project_structure(context)

  return context
end

-- Enhanced project type detection
function M.detect_project_type(context)
  local root = context.git_root
  local indicators = {
    -- JavaScript/TypeScript projects
    {
      files = { 'package.json', 'yarn.lock', 'pnpm-lock.yaml' },
      type = 'javascript/typescript',
      language = 'javascript',
    },
    -- Python projects
    {
      files = { 'requirements.txt', 'pyproject.toml', 'setup.py', 'Pipfile', 'poetry.lock' },
      type = 'python',
      language = 'python',
    },
    -- Go projects
    {
      files = { 'go.mod', 'go.sum' },
      type = 'go',
      language = 'go',
    },
    -- Rust projects
    {
      files = { 'Cargo.toml', 'Cargo.lock' },
      type = 'rust',
      language = 'rust',
    },
    -- Java projects
    {
      files = { 'pom.xml', 'build.gradle', 'build.gradle.kts' },
      type = 'java',
      language = 'java',
    },
    -- .NET projects
    {
      files = { '*.csproj', '*.sln', 'project.json' },
      type = 'dotnet',
      language = 'csharp',
    },
    -- Ruby projects
    {
      files = { 'Gemfile', 'Gemfile.lock', '*.gemspec' },
      type = 'ruby',
      language = 'ruby',
    },
    -- PHP projects
    {
      files = { 'composer.json', 'composer.lock' },
      type = 'php',
      language = 'php',
    },
  }

  for _, indicator in ipairs(indicators) do
    for _, file_pattern in ipairs(indicator.files) do
      local files = vim.fn.glob(root .. '/' .. file_pattern, false, true)
      if #files > 0 then
        context.project_type = indicator.type
        context.language = indicator.language
        context.config_files = vim.list_extend(context.config_files, files)
        break
      end
    end
    if context.project_type ~= 'unknown' then
      break
    end
  end

  return context
end

-- Enhanced framework detection
function M.detect_framework(context)
  local root = context.git_root

  if context.project_type == 'javascript/typescript' then
    context.framework = M.detect_js_framework(root)
  elseif context.project_type == 'python' then
    context.framework = M.detect_python_framework(root)
  elseif context.project_type == 'go' then
    context.framework = M.detect_go_framework(root)
  elseif context.project_type == 'rust' then
    context.framework = M.detect_rust_framework(root)
  elseif context.project_type == 'java' then
    context.framework = M.detect_java_framework(root)
  end

  return context
end

-- JavaScript/TypeScript framework detection
function M.detect_js_framework(root)
  -- Check for Next.js
  if
    vim.fn.filereadable(root .. '/next.config.js') == 1
    or vim.fn.filereadable(root .. '/next.config.ts') == 1
    or vim.fn.isdirectory(root .. '/pages') == 1
    or vim.fn.isdirectory(root .. '/app') == 1
  then
    return 'nextjs'
  end

  -- Check for Nuxt.js
  if vim.fn.filereadable(root .. '/nuxt.config.js') == 1 or vim.fn.filereadable(root .. '/nuxt.config.ts') == 1 then
    return 'nuxtjs'
  end

  -- Check for SvelteKit
  if vim.fn.filereadable(root .. '/svelte.config.js') == 1 then
    return 'sveltekit'
  end

  -- Check for Vite
  if vim.fn.filereadable(root .. '/vite.config.js') == 1 or vim.fn.filereadable(root .. '/vite.config.ts') == 1 then
    return 'vite'
  end

  -- Check for Create React App
  if vim.fn.isdirectory(root .. '/public') == 1 and vim.fn.filereadable(root .. '/public/index.html') == 1 then
    return 'create-react-app'
  end

  -- Check for Angular
  if vim.fn.filereadable(root .. '/angular.json') == 1 then
    return 'angular'
  end

  -- Check for Vue
  if vim.fn.filereadable(root .. '/vue.config.js') == 1 then
    return 'vue'
  end

  -- Check for Express (look at package.json)
  local package_json = root .. '/package.json'
  if vim.fn.filereadable(package_json) == 1 then
    local content = vim.fn.readfile(package_json)
    local json_str = table.concat(content, '\n')

    if json_str:match '"express"' then
      return 'express'
    elseif json_str:match '"@nestjs/core"' then
      return 'nestjs'
    elseif json_str:match '"fastify"' then
      return 'fastify'
    elseif json_str:match '"react"' then
      return 'react'
    elseif json_str:match '"vue"' then
      return 'vue'
    elseif json_str:match '"svelte"' then
      return 'svelte'
    end
  end

  return nil
end

-- Python framework detection
function M.detect_python_framework(root)
  -- Check for Django
  if vim.fn.filereadable(root .. '/manage.py') == 1 or vim.fn.isdirectory(root .. '/django') == 1 then
    return 'django'
  end

  -- Check for Flask
  if vim.fn.glob(root .. '/**/app.py', false, true)[1] or vim.fn.glob(root .. '/**/wsgi.py', false, true)[1] then
    local requirements_files = { 'requirements.txt', 'pyproject.toml', 'Pipfile' }
    for _, req_file in ipairs(requirements_files) do
      local file_path = root .. '/' .. req_file
      if vim.fn.filereadable(file_path) == 1 then
        local content = table.concat(vim.fn.readfile(file_path), '\n')
        if content:match 'Flask' then
          return 'flask'
        elseif content:match 'fastapi' then
          return 'fastapi'
        end
      end
    end
  end

  return nil
end

-- Go framework detection
function M.detect_go_framework(root)
  local go_mod = root .. '/go.mod'
  if vim.fn.filereadable(go_mod) == 1 then
    local content = table.concat(vim.fn.readfile(go_mod), '\n')

    if content:match 'github%.com/gin%-gonic/gin' then
      return 'gin'
    elseif content:match 'github%.com/gorilla/mux' then
      return 'gorilla'
    elseif content:match 'github%.com/labstack/echo' then
      return 'echo'
    elseif content:match 'github%.com/gofiber/fiber' then
      return 'fiber'
    end
  end

  return nil
end

-- Rust framework detection
function M.detect_rust_framework(root)
  local cargo_toml = root .. '/Cargo.toml'
  if vim.fn.filereadable(cargo_toml) == 1 then
    local content = table.concat(vim.fn.readfile(cargo_toml), '\n')

    if content:match 'actix%-web' then
      return 'actix-web'
    elseif content:match 'warp' then
      return 'warp'
    elseif content:match 'axum' then
      return 'axum'
    elseif content:match 'rocket' then
      return 'rocket'
    end
  end

  return nil
end

-- Java framework detection
function M.detect_java_framework(root)
  -- Check for Spring Boot
  if vim.fn.glob(root .. '/**/application.properties', false, true)[1] or vim.fn.glob(root .. '/**/application.yml', false, true)[1] then
    return 'spring-boot'
  end

  -- Check pom.xml or build.gradle for dependencies
  local build_files = { 'pom.xml', 'build.gradle', 'build.gradle.kts' }
  for _, build_file in ipairs(build_files) do
    local file_path = root .. '/' .. build_file
    if vim.fn.filereadable(file_path) == 1 then
      local content = table.concat(vim.fn.readfile(file_path), '\n')

      if content:match 'spring%-boot' then
        return 'spring-boot'
      elseif content:match 'quarkus' then
        return 'quarkus'
      elseif content:match 'micronaut' then
        return 'micronaut'
      end
    end
  end

  return nil
end

-- Analyze project dependencies
function M.analyze_dependencies(context)
  local root = context.git_root

  if context.project_type == 'javascript/typescript' then
    context.package_info = M.analyze_package_json(root .. '/package.json')
  elseif context.project_type == 'python' then
    context.dependencies = M.analyze_python_deps(root)
  elseif context.project_type == 'go' then
    context.dependencies = M.analyze_go_deps(root .. '/go.mod')
  elseif context.project_type == 'rust' then
    context.dependencies = M.analyze_cargo_deps(root .. '/Cargo.toml')
  end

  return context
end

-- Analyze package.json for JavaScript/TypeScript projects
function M.analyze_package_json(package_json_path)
  if vim.fn.filereadable(package_json_path) == 0 then
    return {}
  end

  local content = vim.fn.readfile(package_json_path)
  local ok, package_data = pcall(vim.fn.json_decode, table.concat(content, '\n'))

  if not ok then
    return {}
  end

  local info = {
    name = package_data.name or 'unknown',
    version = package_data.version or 'unknown',
    scripts = package_data.scripts or {},
    dependencies = package_data.dependencies or {},
    devDependencies = package_data.devDependencies or {},
    main_dependencies = {},
    dev_tools = {},
  }

  -- Categorize important dependencies
  local important_deps = {
    frameworks = { 'react', 'vue', 'angular', 'svelte', 'next', 'nuxt' },
    build_tools = { 'webpack', 'vite', 'rollup', 'parcel', 'esbuild' },
    testing = { 'jest', 'vitest', 'mocha', 'jasmine', 'cypress', 'playwright' },
    linting = { 'eslint', 'prettier', 'stylelint' },
    styling = { 'tailwindcss', 'styled-components', 'emotion', 'sass' },
  }

  for category, deps in pairs(important_deps) do
    info[category] = {}
    for _, dep in ipairs(deps) do
      if info.dependencies[dep] or info.devDependencies[dep] then
        table.insert(info[category], dep)
      end
    end
  end

  return info
end

-- Analyze Python dependencies
function M.analyze_python_deps(root)
  local deps = {}

  -- Check requirements.txt
  local req_file = root .. '/requirements.txt'
  if vim.fn.filereadable(req_file) == 1 then
    local content = vim.fn.readfile(req_file)
    for _, line in ipairs(content) do
      local dep = line:match '^([^=<>!]+)'
      if dep and not dep:match '^#' then
        table.insert(deps, dep:gsub('%s+', ''))
      end
    end
  end

  -- Check pyproject.toml
  local pyproject_file = root .. '/pyproject.toml'
  if vim.fn.filereadable(pyproject_file) == 1 then
    local content = table.concat(vim.fn.readfile(pyproject_file), '\n')
    -- Basic parsing for dependencies section
    local deps_section = content:match '%[tool%.poetry%.dependencies%](.-)\n%['
    if deps_section then
      for dep in deps_section:gmatch '([%w%-]+)%s*=' do
        if dep ~= 'python' then
          table.insert(deps, dep)
        end
      end
    end
  end

  return deps
end

-- Analyze Go dependencies
function M.analyze_go_deps(go_mod_path)
  if vim.fn.filereadable(go_mod_path) == 0 then
    return {}
  end

  local deps = {}
  local content = vim.fn.readfile(go_mod_path)
  local in_require = false

  for _, line in ipairs(content) do
    if line:match '^require' then
      in_require = true
    elseif line:match '^%)' then
      in_require = false
    elseif in_require or line:match '^require%s+' then
      local dep = line:match '%s*([^%s]+)'
      if dep and not dep:match '^%(' and not dep:match '^%)' then
        table.insert(deps, dep)
      end
    end
  end

  return deps
end

-- Analyze Cargo dependencies
function M.analyze_cargo_deps(cargo_toml_path)
  if vim.fn.filereadable(cargo_toml_path) == 0 then
    return {}
  end

  local deps = {}
  local content = vim.fn.readfile(cargo_toml_path)
  local in_dependencies = false

  for _, line in ipairs(content) do
    if line:match '^%[dependencies%]' then
      in_dependencies = true
    elseif line:match '^%[' then
      in_dependencies = false
    elseif in_dependencies and line:match '^[%w%-_]+%s*=' then
      local dep = line:match '^([%w%-_]+)'
      if dep then
        table.insert(deps, dep)
      end
    end
  end

  return deps
end

-- Get Git information
function M.get_git_information(context)
  if context.git_root == '' then
    return context
  end

  -- Get recent commits
  local recent_commits = vim.fn.system('git log --oneline -10 2>/dev/null'):gsub('\n$', '')
  if vim.v.shell_error == 0 and recent_commits ~= '' then
    for line in recent_commits:gmatch '[^\n]+' do
      table.insert(context.recent_changes, line)
    end
  end

  -- Get modified files
  local git_status = vim.fn.system('git status --porcelain 2>/dev/null'):gsub('\n$', '')
  if vim.v.shell_error == 0 and git_status ~= '' then
    for line in git_status:gmatch '[^\n]+' do
      local status = line:sub(1, 2)
      local file = line:sub(4)
      table.insert(context.modified_files, { status = status, file = file })
    end
  end

  -- Get current branch
  local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', '')
  if vim.v.shell_error == 0 then
    context.current_branch = branch
  end

  return context
end

-- Analyze project structure
function M.analyze_project_structure(context)
  local root = context.git_root
  local structure = {
    directories = {},
    important_files = {},
    test_directories = {},
    config_directories = {},
  }

  -- Common important directories to analyze
  local important_dirs = {
    'src',
    'lib',
    'app',
    'pages',
    'components',
    'utils',
    'hooks',
    'tests',
    'test',
    '__tests__',
    'spec',
    'e2e',
    'config',
    'configs',
    'settings',
    'docs',
    'documentation',
    'public',
    'static',
    'assets',
    'api',
    'server',
    'backend',
  }

  for _, dir in ipairs(important_dirs) do
    local dir_path = root .. '/' .. dir
    if vim.fn.isdirectory(dir_path) == 1 then
      table.insert(structure.directories, dir)

      -- Categorize directories
      if dir:match 'test' or dir:match 'spec' or dir:match 'e2e' then
        table.insert(structure.test_directories, dir)
      elseif dir:match 'config' or dir:match 'settings' then
        table.insert(structure.config_directories, dir)
      end
    end
  end

  -- Important files to track
  local important_files = {
    'README.md',
    'README.rst',
    'README.txt',
    'CHANGELOG.md',
    'CHANGELOG.rst',
    'CONTRIBUTING.md',
    'LICENSE',
    'LICENSE.md',
    'LICENSE.txt',
    '.gitignore',
    '.gitattributes',
    'Dockerfile',
    'docker-compose.yml',
    '.env',
    '.env.example',
    'tsconfig.json',
    'jsconfig.json',
    '.eslintrc.js',
    '.eslintrc.json',
    'eslint.config.js',
    'prettier.config.js',
    '.prettierrc',
    'tailwind.config.js',
    'tailwind.config.ts',
  }

  for _, file in ipairs(important_files) do
    if vim.fn.filereadable(root .. '/' .. file) == 1 then
      table.insert(structure.important_files, file)
    end
  end

  context.structure = structure
  return context
end

-- Enhanced AI context integration
function M.get_ai_context()
  local core = require 'custom.ai-ultra.core'
  local project_ctx = M.get_project_context()
  local current_file = vim.fn.expand '%:p'
  local relative_file = vim.fn.expand '%:.'

  -- Get enhanced file context
  local file_context = core.get_context()

  -- Get file relationships
  local related_files = M.get_related_files(current_file)

  -- Get imports/dependencies
  local imports = M.get_file_imports()

  return {
    project = project_ctx,
    current_file = {
      absolute_path = current_file,
      relative_path = relative_file,
      context = file_context,
      related_files = related_files,
      imports = imports,
    },
    diagnostics = vim.diagnostic.get(0),
    lsp_info = M.get_lsp_info(),
    workspace_symbols = M.get_workspace_symbols(),
  }
end

-- Get files related to current file
function M.get_related_files(current_file)
  local related = {}
  local basename = vim.fn.fnamemodify(current_file, ':t:r')
  local dir = vim.fn.fnamemodify(current_file, ':h')
  local ext = vim.fn.fnamemodify(current_file, ':e')

  -- Test file patterns
  local test_patterns = {
    basename .. '.test.' .. ext,
    basename .. '.spec.' .. ext,
    basename .. '_test.' .. ext,
    'test_' .. basename .. '.' .. ext,
    '__tests__/' .. basename .. '.test.' .. ext,
    'tests/' .. basename .. '.test.' .. ext,
  }

  for _, pattern in ipairs(test_patterns) do
    local test_file = dir .. '/' .. pattern
    if vim.fn.filereadable(test_file) == 1 then
      table.insert(related, { type = 'test', file = test_file })
    end
  end

  -- Type definition files (TypeScript)
  if ext == 'ts' or ext == 'tsx' or ext == 'js' or ext == 'jsx' then
    local type_patterns = {
      basename .. '.d.ts',
      'types/' .. basename .. '.ts',
      '@types/' .. basename .. '.d.ts',
    }

    for _, pattern in ipairs(type_patterns) do
      local type_file = dir .. '/' .. pattern
      if vim.fn.filereadable(type_file) == 1 then
        table.insert(related, { type = 'types', file = type_file })
      end
    end
  end

  -- Component pairs (React)
  if ext == 'tsx' or ext == 'jsx' then
    local component_patterns = {
      basename .. '.module.css',
      basename .. '.module.scss',
      basename .. '.styled.ts',
      basename .. '.styles.ts',
      'styles/' .. basename .. '.css',
    }

    for _, pattern in ipairs(component_patterns) do
      local style_file = dir .. '/' .. pattern
      if vim.fn.filereadable(style_file) == 1 then
        table.insert(related, { type = 'styles', file = style_file })
      end
    end
  end

  return related
end

-- Get imports from current file
function M.get_file_imports()
  local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)
  local imports = {
    local_imports = {},
    external_imports = {},
    relative_imports = {},
  }

  for _, line in ipairs(lines) do
    local trimmed = line:match '^%s*(.-)%s*$'

    -- JavaScript/TypeScript imports
    local js_import = trimmed:match '^import.-from%s+[\'"]([^\'"]+)[\'"]'
    if js_import then
      if js_import:match '^%.' then
        table.insert(imports.relative_imports, js_import)
      elseif js_import:match '^[%w@]' then
        table.insert(imports.external_imports, js_import)
      else
        table.insert(imports.local_imports, js_import)
      end
    end

    -- Python imports
    local py_import = trimmed:match '^from%s+([%w%.]+)%s+import' or trimmed:match '^import%s+([%w%.]+)'
    if py_import then
      if py_import:match '^%.' then
        table.insert(imports.relative_imports, py_import)
      elseif py_import:match '^[%w_]+$' and not py_import:match '^[A-Z]' then
        table.insert(imports.external_imports, py_import)
      else
        table.insert(imports.local_imports, py_import)
      end
    end

    -- Go imports
    if vim.bo.filetype == 'go' and trimmed:match '^import' then
      local go_import = trimmed:match '"([^"]+)"'
      if go_import then
        if go_import:match '/' then
          table.insert(imports.external_imports, go_import)
        else
          table.insert(imports.local_imports, go_import)
        end
      end
    end
  end

  return imports
end

-- Get LSP information
function M.get_lsp_info()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  local lsp_info = {}

  for _, client in ipairs(clients) do
    table.insert(lsp_info, {
      name = client.name,
      root_dir = client.config.root_dir,
      filetypes = client.config.filetypes,
      capabilities = {
        completion = client.server_capabilities.completionProvider ~= nil,
        hover = client.server_capabilities.hoverProvider,
        definition = client.server_capabilities.definitionProvider,
        references = client.server_capabilities.referencesProvider,
        rename = client.server_capabilities.renameProvider,
      },
    })
  end

  return lsp_info
end

-- Get workspace symbols
function M.get_workspace_symbols()
  local symbols = {}

  -- Use LSP workspace symbols if available
  local params = { query = '' }
  local results = vim.lsp.buf_request_sync(0, 'workspace/symbol', params, 1000)

  if results then
    for _, result in pairs(results) do
      if result.result then
        for _, symbol in ipairs(result.result) do
          table.insert(symbols, {
            name = symbol.name,
            kind = symbol.kind,
            location = symbol.location,
          })
        end
      end
    end
  end

  return symbols
end

-- Enhanced AI request with full workspace context
function M.ask_with_context(prompt, opts)
  opts = opts or {}
  local context = M.get_ai_context()

  -- Build comprehensive context prompt
  local context_prompt = string.format(
    [[=== COMPREHENSIVE WORKSPACE CONTEXT ===

## Project Information
- **Type**: %s
- **Language**: %s  
- **Framework**: %s
- **Root**: %s

## Current File Context
- **File**: %s
- **Type**: %s
- **Function**: %s
- **Diagnostics**: %d issues

## Project Structure
- **Directories**: %s
- **Important Files**: %s
- **Test Directories**: %s

## Dependencies & Imports
- **External**: %s
- **Local**: %s
- **Relative**: %s

## Recent Development Activity
%s

## LSP Information
- **Active LSP**: %s

═══════════════════════════════════════════

## Your Request:
%s]],
    context.project.project_type,
    context.project.language,
    context.project.framework or 'none',
    vim.fn.fnamemodify(context.project.git_root, ':t'),

    context.current_file.relative_path,
    context.current_file.context.filetype,
    context.current_file.context.function_name or 'none',
    context.current_file.context.diagnostic_count,

    table.concat(context.project.structure.directories, ', '),
    table.concat(context.project.structure.important_files, ', '),
    table.concat(context.project.structure.test_directories, ', '),

    table.concat(context.current_file.imports.external_imports, ', '),
    table.concat(context.current_file.imports.local_imports, ', '),
    table.concat(context.current_file.imports.relative_imports, ', '),

    table.concat(vim.list_slice(context.project.recent_changes, 1, 3), '\n'),

    table.concat(
      vim.tbl_map(function(lsp)
        return lsp.name
      end, context.lsp_info),
      ', '
    ),

    prompt
  )

  -- Use core AI functionality with enhanced context
  local core = require 'custom.ai-ultra.core'
  core.ask(context_prompt, opts)
end

-- Track AI usage with workspace context
function M.track_ai_usage(source)
  -- This can be extended to track workspace-specific usage patterns
  local ok_models, models = pcall(require, 'custom.ai-ultra.models')
  if ok_models then
    models.track_usage()
  end
end

function M.setup()
  vim.notify('AI Ultra Workspace: Ready', vim.log.levels.DEBUG)
end

return M
