# Strategy Applier Command

Apply a specific development strategy to the current task.

## Instructions

1. Parse the strategy name from: `$ARGUMENTS`
2. Load the corresponding module and apply its guidelines

Supported strategies:
- `tdd` - Test-Driven Development (load testing module)
- `ddd` - Domain-Driven Design (load principles module)
- `security-first` - Security-first approach (load security module)
- `performance` - Performance optimization focus (load performance module)

Strategy to module mapping:
- `tdd` → Load `testing` + `workflow` modules
- `ddd` → Load `principles` module, focus on domain modeling
- `security-first` → Load `security` module
- `performance` → Load `performance` module

3. Summarize the key practices for the selected strategy
4. Apply these practices throughout the current session

Example usage:
- `/apply tdd` - Apply Test-Driven Development
- `/apply security-first` - Apply security-first approach
