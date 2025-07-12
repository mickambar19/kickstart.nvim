-- Update your lua/custom/ai/prompts.lua with anti-truncation prompts
local M = {}

-- Enhanced base prompts that discourage truncation
M.base_prompts = {
  fix = {
    text = 'Fix the issues in this code. Provide complete, working solutions. Explain each fix clearly.',
    system = 'You are a staff software engineer with extensive expertise in this technology. Always provide complete fixes with full explanations. Never truncate your response.',
  },
  explain = {
    text = 'Explain this code clearly and comprehensively. Cover all important aspects and provide examples.',
    system = 'You are a teacher from a well-known university such as Stanford. Explain effectively and concisely. Give complete explanations with examples whenever you think this could help with understanding. Finish all your thoughts.',
  },

  tests = {
    text = [[Generate comprehensive test suite including:

**IMPORTANT**: Please provide complete, untruncated response with all test cases.

Required test coverage:
1. Happy path scenarios (normal usage)
2. Edge cases (boundaries, empty inputs, null/undefined)
3. Error scenarios (invalid inputs, exceptions)
4. Integration tests (if applicable)
5. Mock setup and configuration

For each test:
- Complete test function with descriptive name
- All necessary imports and setup
- Clear assertions with meaningful messages
- Comments explaining test purpose

Please ensure you complete ALL test cases in your response. Do not truncate or summarize.]],
    system = [[You are a testing expert. Write complete, comprehensive test suites. 
Always finish your entire response - never truncate test code or explanations.
If the response would be long, that's perfectly fine - provide complete working tests.]],
  },

  docs = {
    text = [[Add comprehensive documentation including:
- Function/class descriptions
- Parameter and return type documentation
- Usage examples
- Edge cases and gotchas

Provide complete documentation - do not truncate explanations.]],
    system = 'You are a technical writer. Write complete, thorough documentation. Always finish your entire response.',
  },

  review = {
    text = [[Review this code comprehensively for:
1. Bugs and potential issues
2. Performance problems  
3. Security vulnerabilities
4. Code smells and maintainability
5. Best practices adherence

Provide complete analysis with specific recommendations and examples.]],
    system = 'You are a senior code reviewer. Provide thorough, complete reviews. Never truncate your analysis.',
  },

  refactor = {
    text = 'Refactor this code for better maintainability. Provide the complete refactored version with explanations.',
    system = 'You are a refactoring expert. Show complete refactored code with full explanations.',
  },

  optimize = {
    text = [[Optimize this code for performance and readability. Provide:
1. Complete optimized code
2. Explanation of all optimizations
3. Performance impact analysis
4. Before/after comparisons

Ensure your response is complete and untruncated.]],
    system = 'You are a performance expert. Provide complete optimized code with thorough explanations.',
  },
}

-- Enhanced test-specific prompts
M.comprehensive_test_prompt = function(test_type)
  local base = [[Generate a complete test suite for this code. 

**CRITICAL**: Provide the ENTIRE test file - do not truncate your response.

Include:
1. **File header and imports**
   - All necessary testing framework imports
   - Module imports being tested
   - Mock library imports if needed

2. **Test setup and teardown**
   - beforeEach/beforeAll setup
   - afterEach/afterAll cleanup
   - Mock configurations

3. **Happy path tests**
   - Normal usage scenarios
   - Expected inputs and outputs
   - Successful operations

4. **Edge case tests** 
   - Boundary values (0, 1, -1, max/min values)
   - Empty inputs (null, undefined, empty arrays/objects)
   - Special characters and unicode
   - Large datasets

5. **Error handling tests**
   - Invalid input types
   - Out-of-range values
   - Network failures (if applicable)
   - Exception scenarios

6. **Integration tests** (if applicable)
   - Component interactions
   - External service mocks
   - Database interactions

7. **Performance tests** (if relevant)
   - Load testing for heavy operations
   - Memory usage validation

Format each test with:
- Descriptive test name using "should..." pattern
- Clear arrange/act/assert structure
- Meaningful assertion messages
- Inline comments for complex logic

Please complete the ENTIRE test file - do not stop mid-way or truncate.]]

  if test_type == 'react' then
    return base
      .. [[

For React components, also include:
- Component rendering tests
- Props validation tests  
- Event handler tests
- State change tests
- Lifecycle method tests (if class components)
- Hook tests (if functional components)
- Accessibility tests
- Snapshot tests (if appropriate)

Use React Testing Library best practices.]]
  end

  return base
end

-- Anti-truncation system prompts
M.system_prompts = {
  comprehensive = [[You are an expert developer assistant. Your responses must be:
1. COMPLETE - never truncate code blocks or explanations
2. DETAILED - provide thorough explanations and examples  
3. WORKING - all code should be functional and tested
4. FINISHED - always complete your entire thought/response

If a response would be very long, that's completely fine. Users prefer complete, working solutions over truncated partial responses.]],

  testing_expert = [[You are a comprehensive testing expert. When generating tests:
1. Always provide COMPLETE test files with all imports
2. Include ALL test categories (happy path, edge cases, errors)
3. Write FULL test implementations, not just outlines
4. Never truncate test code or stop mid-function
5. Include complete setup/teardown code
6. Provide working mock configurations

Quality over brevity - users need complete, working test suites.]],
}

-- Function to get enhanced prompt with anti-truncation instructions
function M.get_enhanced_prompt(action, context)
  local base = M.base_prompts[action]
  if not base then
    return nil
  end

  -- Add anti-truncation instructions
  local enhanced_text = base.text .. '\n\n**IMPORTANT**: Please provide your complete response. Do not truncate or cut off your answer mid-way.'

  -- For test generation, use comprehensive prompt
  if action == 'tests' then
    enhanced_text = M.comprehensive_test_prompt(context.framework)
  end

  return {
    text = enhanced_text,
    system = base.system .. ' Always complete your entire response without truncation.',
  }
end

return M
