# Module Loader Command

Load the specified module(s) from the user's global config directory.

## Instructions

1. Parse the module name(s) from: `$ARGUMENTS`
2. Read the corresponding module file(s) from `claude-prompts/`

Module name to file mapping:
- `principles` → `claude-prompts/01-principles.md`
- `workflow` → `claude-prompts/02-workflow.md`
- `task-management` → `claude-prompts/03-task-management.md`
- `mcp-services` → `claude-prompts/04-mcp-services.md`
- `dev-logs` → `claude-prompts/05-dev-logs.md`
- `testing` → `claude-prompts/06-testing.md`
- `security` → `claude-prompts/07-security.md`
- `performance` → `claude-prompts/08-performance.md`
- `code-review` → `claude-prompts/09-code-review.md`
- `tech-stack` → `claude-prompts/10-tech-stack.md`
- `ai-collaboration` → `claude-prompts/11-ai-collaboration.md`
- `project-templates` → `claude-prompts/12-project-templates.md`
- `quick-ref` → `claude-prompts/QUICK_REFERENCE.md`

3. If multiple modules are specified (comma-separated), load all of them
4. After reading, confirm which modules were loaded and summarize key points
5. Apply the loaded module's guidelines to the current session

Example usage:
- `/load principles` - Load principles module
- `/load workflow, testing` - Load multiple modules
