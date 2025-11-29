# Dev Log Command

Initialize or update the AI development logging system.

## Instructions

1. Parse the action from: `$ARGUMENTS`

Supported actions:
- `init` - Initialize dev-logs system in current project
- `status` - Show current logging status
- `entry` - Create a new log entry
- `summary` - Generate session summary

2. For `init`:
   - Load `dev-logs` module from `claude-prompts/05-dev-logs.md`
   - Create `.ai-dev-logs/` directory structure
   - Initialize tracking files

3. For `status`:
   - Show current project's logging configuration
   - Display recent entries count

4. For `entry`:
   - Create a timestamped log entry
   - Record current task context

5. For `summary`:
   - Generate a summary of the current session
   - Update progress metrics

Example usage:
- `/devlog init` - Initialize dev-logs system
- `/devlog entry` - Create a new log entry
- `/devlog summary` - Generate session summary
