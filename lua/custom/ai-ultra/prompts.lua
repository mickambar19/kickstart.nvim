-- lua/custom/ai-ultra/prompts.lua
-- Enhanced AI prompts with anti-truncation and context awareness

local M = {}

-- Quick prompts for common tasks
M.quick_prompts = {
  security = 'Analyze for security vulnerabilities: XSS, SQL injection, auth issues, OWASP Top 10',
  performance = 'Analyze performance bottlenecks and suggest specific optimizations with examples',
  accessibility = 'Review for accessibility (a11y) issues and WCAG 2.1 compliance with fixes',
  refactor = 'Suggest refactoring improvements for better maintainability and readability',
  tests = 'Generate comprehensive test cases including edge cases and error scenarios',
  types = 'Add comprehensive TypeScript types with proper generics and interfaces',
  docs = 'Add thorough documentation with examples and usage patterns',
  modern = 'Modernize this code using latest language features and best practices',
}

-- Enhanced base prompts with anti-truncation measures
M.base_prompts = {
  explain = {
    text = [[Provide a comprehensive explanation of this code covering:

**IMPORTANT**: Complete your entire response - never truncate explanations.

## Code Analysis
1. **Primary Purpose**: What this code does and why it exists
2. **How It Works**: Step-by-step breakdown of the logic
3. **Key Concepts**: Important patterns, algorithms, or techniques used
4. **Data Flow**: How data moves through the code
5. **Dependencies**: External libraries, modules, or APIs used

## Technical Details
- **Input/Output**: Parameters, return values, side effects
- **Error Handling**: How errors are managed
- **Performance**: Time/space complexity considerations
- **Security**: Any security implications

## Usage Examples
Provide practical examples showing how to use this code.

## Potential Issues
- Edge cases to consider
- Common mistakes when using this code
- Maintenance considerations

Please provide complete explanations for each section.""",

    system = [[You are a senior software engineer and technical educator. 
Provide thorough, complete explanations that help developers understand both the "what" and "why" of code.
Always finish your entire response - never truncate explanations or code examples.
Use clear, professional language appropriate for experienced developers.]],
  },

  fix = {
    text = [[Analyze this code for issues and provide comprehensive fixes:

**CRITICAL**: Provide complete, working solutions - do not truncate your response.

## Issue Analysis
1. **Syntax Errors**: Check for syntax problems
2. **Logic Bugs**: Identify logical flaws
3. **Runtime Errors**: Potential exceptions or crashes
4. **Type Errors**: Incorrect type usage
5. **Performance Issues**: Inefficient patterns
6. **Security Vulnerabilities**: Security risks
7. **Best Practice Violations**: Code quality issues

## Complete Solutions
For each issue found:
- **Problem Description**: What's wrong and why
- **Impact**: How this affects the application
- **Fixed Code**: Complete corrected implementation
- **Explanation**: Why this fix works
- **Prevention**: How to avoid similar issues

## Additional Improvements
Suggest enhancements beyond just fixing bugs:
- Code organization
- Error handling improvements
- Performance optimizations
- Maintainability enhancements

Provide all fixes with complete, working code examples.""",

    system = [[You are an expert debugging specialist and code reviewer.
Identify all issues comprehensively and provide complete, working solutions.
Always include full code implementations - never truncate fixes or explanations.
Focus on creating robust, maintainable solutions.]],
  },

  tests = {
    text = [[Generate a comprehensive test suite for this code:

**ESSENTIAL**: Provide the complete test file - do not truncate any part of your response.

## Test File Structure
```javascript
// Complete imports section
import { ... } from '...'
import { describe, it, expect, beforeEach, afterEach } from '...'

// Mock setup if needed
jest.mock('...')

describe('ComponentName', () => {
  // Setup and teardown
  beforeEach(() => { ... })
  afterEach(() => { ... })

  // Test categories follow below
})
```

## Required Test Categories

### 1. Happy Path Tests
- Normal usage scenarios
- Expected inputs and outputs
- Successful operations
- Valid data flows

### 2. Edge Case Tests
- Boundary values (0, 1, -1, max/min)
- Empty inputs (null, undefined, empty arrays/objects)
- Large datasets
- Special characters and unicode

### 3. Error Handling Tests
- Invalid input types
- Out-of-range values
- Network failures (if applicable)
- Exception scenarios
- Timeout conditions

### 4. Integration Tests (if applicable)
- Component interactions
- External service mocks
- Database operations
- API calls

### 5. Performance Tests (if relevant)
- Load testing for heavy operations
- Memory usage validation
- Rendering performance (React)

## Test Implementation Requirements
- Use descriptive test names with "should..." pattern
- Clear arrange/act/assert structure
- Meaningful assertion messages
- Proper mock configurations
- Complete setup and teardown

**Provide the entire test file - complete all test implementations.**""",

    system = [[You are a comprehensive testing expert specializing in creating thorough test suites.
When generating tests:
1. Always provide COMPLETE test files with all imports and setup
2. Include ALL test categories (happy path, edge cases, errors)  
3. Write FULL test implementations, never just outlines
4. Never truncate test code or stop mid-function
5. Include complete mock configurations where needed
6. Provide working test setup and teardown code

Your goal is to create production-ready, comprehensive test suites that provide excellent coverage.]],
  },

  docs = {
    text = [[Add comprehensive documentation to this code:

**REQUIREMENT**: Complete all documentation sections - do not truncate your response.

## Documentation Requirements

### Function/Class Documentation
```typescript
/**
 * Brief description of what this function/class does
 * 
 * @param {Type} paramName - Description of parameter, including constraints
 * @param {Type} optionalParam - Optional parameter description
 * @returns {Type} Description of return value and possible states
 * 
 * @example
 * ```typescript
 * // Basic usage example
 * const result = functionName(param1, param2);
 * console.log(result); // Expected output
 * ```
 * 
 * @example
 * ```typescript
 * // Advanced usage example
 * const advancedResult = functionName(complexParam, { options });
 * ```
 * 
 * @throws {ErrorType} When this error condition occurs
 * @since Version when this was added
 * @see {@link RelatedFunction} for related functionality
 */
```

### Code Documentation
1. **Purpose Comments**: Why this code exists
2. **Algorithm Explanations**: Complex logic breakdown
3. **Business Logic**: Domain-specific explanations
4. **Performance Notes**: Complexity and optimization details
5. **Security Considerations**: Important security notes
6. **Usage Warnings**: Potential pitfalls or limitations

### API Documentation (if applicable)
- Endpoint descriptions
- Request/response formats
- Authentication requirements
- Rate limiting information
- Error response codes

### README Sections (if applicable)
- Installation instructions
- Configuration options
- Usage examples
- API reference
- Contributing guidelines

Provide complete documentation with real, working examples.""",

    system = [[You are a technical documentation specialist.
Create comprehensive, accurate documentation that helps developers understand and use code effectively.
Always provide complete examples and finish all documentation sections.
Use clear, professional language with proper formatting.]],
  },

  review = {
    text = [[Conduct a comprehensive code review covering all aspects:

**MANDATE**: Provide complete analysis - do not truncate any section of your review.

## Code Quality Assessment

### 1. Correctness & Logic
- **Bugs**: Identify logical errors and potential runtime issues
- **Edge Cases**: Missing error handling or boundary conditions
- **Type Safety**: Incorrect type usage or missing type annotations
- **Algorithm Correctness**: Verify logic implements requirements correctly

### 2. Performance Analysis
- **Time Complexity**: Algorithm efficiency analysis
- **Space Complexity**: Memory usage patterns
- **Database Queries**: N+1 problems, missing indexes
- **Rendering Performance**: Unnecessary re-renders (React)
- **Bundle Size**: Import optimization opportunities

### 3. Security Review
- **Input Validation**: SQL injection, XSS vulnerabilities
- **Authentication**: Access control and authorization flaws
- **Data Exposure**: Sensitive information leakage
- **API Security**: Rate limiting, CORS, headers
- **Dependencies**: Known vulnerable packages

### 4. Maintainability
- **Code Organization**: Structure and modularity
- **Naming Conventions**: Clear, descriptive identifiers
- **Function Complexity**: Single responsibility principle
- **Documentation**: Comments and self-documenting code
- **Test Coverage**: Adequate testing strategy

### 5. Best Practices Compliance
- **Language Standards**: Modern language features usage
- **Framework Patterns**: Proper framework conventions
- **Design Patterns**: Appropriate pattern application
- **Error Handling**: Comprehensive error management
- **Logging**: Appropriate logging practices

## Detailed Recommendations
For each issue:
- **Severity**: Critical/High/Medium/Low
- **Location**: Specific line numbers or sections
- **Problem**: Clear description of the issue
- **Solution**: Concrete fix with code examples
- **Rationale**: Why this improvement matters

## Summary
- **Overall Quality Score**: X/10 with justification
- **Priority Fixes**: Most important issues to address
- **Future Improvements**: Nice-to-have enhancements

Provide complete analysis with specific, actionable recommendations.""",

    system = [[You are a senior staff engineer conducting thorough code reviews.
Provide comprehensive, constructive feedback that helps improve code quality.
Always complete your entire review - never truncate analysis or recommendations.
Be specific, actionable, and educational in your feedback.]],
  },

  optimize = {
    text = [[Optimize this code for maximum performance and efficiency:

**CRITICAL**: Provide complete optimized implementations - do not truncate solutions.

## Performance Analysis

### Current Performance Characteristics
1. **Time Complexity**: Analyze current algorithm efficiency
2. **Space Complexity**: Memory usage patterns
3. **Bottlenecks**: Identify performance-critical sections
4. **Resource Usage**: CPU, memory, I/O analysis

### Optimization Opportunities

#### Algorithm Optimizations
- **Data Structures**: More efficient data structure choices
- **Algorithm Improvements**: Better algorithmic approaches
- **Caching Strategies**: Memoization and result caching
- **Lazy Loading**: Defer expensive operations

#### Framework-Specific Optimizations
- **React**: memo, useCallback, useMemo, code splitting
- **Database**: Query optimization, indexing strategies
- **Network**: Request batching, compression, CDN usage
- **Bundle**: Tree shaking, code splitting, lazy imports

#### System-Level Optimizations
- **Concurrency**: Parallel processing opportunities
- **I/O Operations**: Asynchronous patterns, batching
- **Memory Management**: Object pooling, garbage collection
- **CPU Usage**: Computational efficiency improvements

## Optimized Implementation

### Complete Optimized Code
```typescript
// Provide full, optimized implementation here
// Include all necessary imports and dependencies
// Show before/after comparisons where helpful
```

### Performance Improvements
- **Benchmarks**: Expected performance gains
- **Memory Reduction**: Memory usage improvements
- **User Experience**: Perceived performance enhancements
- **Scalability**: How optimizations improve at scale

### Implementation Notes
- **Breaking Changes**: Any API changes required
- **Migration Path**: How to safely deploy optimizations
- **Monitoring**: Metrics to track optimization success
- **Fallbacks**: Graceful degradation strategies

Provide complete, production-ready optimized code with full explanations.""",

    system = [[You are a performance optimization expert with deep knowledge of algorithms, data structures, and system design.
Provide comprehensive optimizations that significantly improve performance while maintaining code quality.
Always provide complete, working optimized implementations - never truncate code or explanations.
Consider real-world constraints and trade-offs in your optimizations.]],
  },

  refactor = {
    text = [[Refactor this code for maximum maintainability and code quality:

**REQUIREMENT**: Provide complete refactored implementation - finish all code and explanations.

## Refactoring Analysis

### Current Code Issues
1. **Complexity**: Functions that are too large or complex
2. **Duplication**: Repeated code patterns
3. **Coupling**: Tight dependencies between components
4. **Naming**: Unclear or misleading identifiers
5. **Structure**: Poor organization or architecture

### Refactoring Strategy

#### SOLID Principles Application
- **Single Responsibility**: Each function/class has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Proper inheritance hierarchies
- **Interface Segregation**: Focused, cohesive interfaces
- **Dependency Inversion**: Depend on abstractions, not concretions

#### Design Pattern Applications
- **Factory Pattern**: Object creation abstraction
- **Strategy Pattern**: Algorithm variation handling
- **Observer Pattern**: Event-driven architectures
- **Command Pattern**: Action encapsulation
- **Decorator Pattern**: Behavior extension

#### Code Organization Improvements
- **Module Structure**: Logical code grouping
- **Function Extraction**: Breaking down complex functions
- **Class Design**: Proper encapsulation and responsibilities
- **File Organization**: Clear file and folder structure

## Complete Refactored Implementation

### Refactored Code Structure
```typescript
// Provide complete refactored implementation
// Include all necessary files and modules
// Show clear separation of concerns
// Demonstrate improved architecture
```

### Refactoring Benefits
1. **Readability**: How code becomes easier to understand
2. **Maintainability**: Simplified future modifications
3. **Testability**: Improved unit testing capabilities
4. **Reusability**: Better component reuse opportunities
5. **Extensibility**: Easier feature additions

### Migration Guide
- **Step-by-step**: Safe refactoring process
- **Testing Strategy**: Ensuring no functionality breaks
- **Rollback Plan**: How to revert if needed
- **Performance Impact**: Any performance considerations

Provide complete, production-ready refactored code with comprehensive explanations.""",

    system = [[You are a software architecture expert specializing in clean code and maintainable design.
Create refactored code that dramatically improves maintainability while preserving functionality.
Always provide complete implementations - never truncate refactored code or explanations.
Focus on creating elegant, sustainable solutions that follow industry best practices.]],
  },

  types = {
    text = [[Add comprehensive TypeScript types to this code:

**ESSENTIAL**: Provide complete type definitions - do not truncate any type implementations.

## Type Analysis & Implementation

### Current Type Issues
1. **Missing Types**: Identify untyped variables and functions
2. **Any Usage**: Replace `any` types with specific types
3. **Type Safety**: Add proper type guards and assertions
4. **Generic Opportunities**: Where generics would improve reusability

### Complete Type Implementation

#### Interface Definitions
```typescript
// Complete interface definitions
interface ComponentProps {
  // All properties with proper types
  requiredProp: string;
  optionalProp?: number;
  children: React.ReactNode;
  onEvent: (data: EventData) => void;
}

interface EventData {
  // Event-specific type definitions
}

// Union types for restricted values
type Status = 'pending' | 'success' | 'error' | 'loading';

// Generic interfaces for reusability
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}
```

#### Function Type Definitions
```typescript
// Complete function signatures with proper types
type AsyncFunction<TInput, TOutput> = (input: TInput) => Promise<TOutput>;

// Event handler types
type EventHandler<T = any> = (event: T) => void;

// Higher-order function types
type HOC<TProps> = <TComponent extends React.ComponentType<TProps>>(
  component: TComponent
) => TComponent;
```

#### Advanced Type Patterns
- **Conditional Types**: Type logic based on conditions
- **Mapped Types**: Transform existing types
- **Template Literal Types**: String manipulation at type level
- **Utility Types**: Pick, Omit, Partial, Required usage
- **Type Guards**: Runtime type checking functions

### Complete Typed Implementation
```typescript
// Provide full implementation with all types applied
// Include proper error handling with typed errors
// Show type-safe API interactions
// Demonstrate proper generic usage
```

### Type Safety Improvements
1. **Compile-time Safety**: Errors caught during development
2. **IntelliSense**: Better IDE support and autocomplete
3. **Refactoring Safety**: Safer code modifications
4. **Documentation**: Types as living documentation
5. **Team Communication**: Clear API contracts

### Type Testing
```typescript
// Type-level tests to ensure type correctness
type TestCases = {
  // Test type assertions
};
```

Provide complete, production-ready TypeScript implementation with comprehensive type coverage.""",

    system = [[You are a TypeScript expert specializing in advanced type systems and type-safe development.
Create comprehensive type definitions that provide maximum type safety and developer experience.
Always provide complete type implementations - never truncate type definitions or code.
Focus on creating robust, maintainable type systems that prevent runtime errors.]],
  },
}

-- Context-aware prompt enhancement
function M.get_prompt(action_name, context)
  local base_prompt = M.base_prompts[action_name]
  if not base_prompt then
    return nil
  end

  -- Clone the base prompt
  local enhanced_prompt = {
    text = base_prompt.text,
    system = base_prompt.system,
  }

  -- Add context-specific enhancements
  if context then
    local context_info = string.format(
      [[

## Current Context
- **File**: %s (%s)
- **Framework**: %s
- **Project Type**: %s
- **Function Context**: %s
- **Test File**: %s
- **Has Diagnostics**: %s issues
- **File Size**: %d lines

Consider this context when providing your response.]],
      context.relative_path or context.filename,
      context.filetype,
      context.framework or 'none',
      context.language_info and context.language_info.paradigm or 'unknown',
      context.function_name or 'none',
      context.is_test and 'Yes' or 'No',
      context.diagnostic_count,
      context.line_count
    )

    enhanced_prompt.text = enhanced_prompt.text .. context_info

    -- Framework-specific enhancements
    if context.framework == 'react' or context.framework == 'nextjs' then
      enhanced_prompt.text = enhanced_prompt.text
        .. [[

## React/Next.js Specific Considerations
- Use modern React patterns (hooks, functional components)
- Consider performance optimizations (memo, useCallback, useMemo)
- Follow React best practices for state management
- Consider accessibility (a11y) requirements
- Use proper TypeScript integration]]
    elseif context.framework == 'django' or context.framework == 'flask' then
      enhanced_prompt.text = enhanced_prompt.text
        .. [[

## Python Web Framework Considerations
- Follow PEP 8 style guidelines
- Use proper type hints
- Consider security best practices (OWASP)
- Implement proper error handling
- Follow framework-specific patterns]]
    elseif context.framework == 'gin' or context.framework == 'echo' then
      enhanced_prompt.text = enhanced_prompt.text
        .. [[

## Go Web Framework Considerations
- Follow Go conventions and idioms
- Implement proper error handling
- Use proper concurrency patterns
- Consider performance and memory efficiency
- Follow Go testing conventions]]
    end

    -- Language-specific enhancements
    if context.filetype == 'typescript' or context.filetype == 'javascript' then
      enhanced_prompt.text = enhanced_prompt.text
        .. [[

## JavaScript/TypeScript Specific Requirements
- Use modern ES features appropriately
- Provide proper TypeScript types if applicable
- Consider async/await patterns
- Follow modern JavaScript best practices
- Consider bundle size implications]]
    elseif context.filetype == 'python' then
      enhanced_prompt.text = enhanced_prompt.text
        .. [[

## Python Specific Requirements
- Follow PEP 8 style guidelines
- Use type hints where appropriate
- Consider Python 3.10+ features
- Follow Pythonic patterns and idioms
- Include proper docstrings]]
    elseif context.filetype == 'go' then
      enhanced_prompt.text = enhanced_prompt.text
        .. [[

## Go Specific Requirements
- Follow Go conventions and idioms
- Implement proper error handling
- Use Go modules properly
- Follow effective Go patterns
- Include proper Go documentation]]
    end
  end

  return enhanced_prompt
end

-- Enhanced prompt for specific scenarios
function M.get_enhanced_prompt(action, context)
  local base = M.get_prompt(action, context)
  if not base then
    return nil
  end

  -- Add anti-truncation instructions based on action
  local anti_truncation_text = ''

  if action == 'tests' then
    anti_truncation_text = [[

**ANTI-TRUNCATION CRITICAL INSTRUCTIONS**:
1. This is a comprehensive test generation request
2. You must provide the COMPLETE test file with ALL implementations
3. Never truncate test functions or stop mid-implementation
4. Include ALL test categories: happy path, edge cases, error handling
5. Provide full mock setups and configurations
6. Complete every test function you start
7. If response would be long, that's expected and required
8. Quality over brevity - provide complete, working test suites]]
  elseif action == 'fix' then
    anti_truncation_text = [[

**ANTI-TRUNCATION CRITICAL INSTRUCTIONS**:
1. Provide COMPLETE fixes for all identified issues
2. Never truncate code solutions or stop mid-fix
3. Include full explanations for each fix
4. Show complete before/after code examples
5. Finish all recommendations and improvements
6. Provide complete, working code implementations]]
  elseif action == 'explain' then
    anti_truncation_text = [[

**ANTI-TRUNCATION CRITICAL INSTRUCTIONS**:
1. Provide COMPLETE explanations for all concepts
2. Never truncate explanations or cut off mid-sentence
3. Finish all sections: purpose, how it works, examples, considerations
4. Include complete code examples with full context
5. Complete all technical details and usage patterns]]
  end

  base.text = base.text .. anti_truncation_text

  return base
end

-- Quick access to common prompt patterns
M.prompt_patterns = {
  -- Code analysis patterns
  analyze_performance = 'Analyze this code for performance bottlenecks and provide specific optimization recommendations with benchmarks.',
  analyze_security = 'Perform comprehensive security analysis following OWASP Top 10 guidelines with specific vulnerability fixes.',
  analyze_accessibility = 'Review for WCAG 2.1 AA compliance and provide specific accessibility improvements with examples.',

  -- Generation patterns
  generate_tests_comprehensive = 'Generate comprehensive test suite including unit, integration, and edge case tests with full implementations.',
  generate_types_strict = 'Add strict TypeScript types with proper generics, utility types, and type guards.',
  generate_docs_complete = 'Add comprehensive documentation with JSDoc/TSDoc, usage examples, and API reference.',

  -- Transformation patterns
  modernize_code = 'Modernize this code using latest language features, best practices, and design patterns.',
  refactor_clean = 'Refactor for clean code principles: SOLID, DRY, proper abstractions, and maintainability.',
  optimize_bundle = 'Optimize for smaller bundle size: tree shaking, code splitting, and efficient imports.',
}

function M.setup()
  vim.notify('AI Ultra Prompts: Ready', vim.log.levels.DEBUG)
end

return M
