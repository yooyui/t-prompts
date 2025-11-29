# Checklist Runner Command

Execute a specific checklist against the current codebase.

## Instructions

1. Parse the checklist type from: `$ARGUMENTS`
2. Load the corresponding module and run its checklist

Supported checklists:
- `security` - Security vulnerability check (OWASP Top 10)
- `performance` - Performance bottleneck check
- `code-quality` - Code quality and best practices
- `accessibility` - Accessibility compliance (a11y)
- `pre-commit` - Pre-commit validation
- `pre-deploy` - Pre-deployment checklist

Checklist to module mapping:
- `security` → Load `security` module, run security audit
- `performance` → Load `performance` module, analyze metrics
- `code-quality` → Load `code-review` + `principles` modules
- `pre-commit` → Run linting, type-check, and tests
- `pre-deploy` → Full validation before deployment

3. Execute the checklist items one by one
4. Report findings with severity levels: Critical / Warning / Info
5. Provide remediation suggestions for any issues found

Example usage:
- `/check security` - Run security audit
- `/check pre-commit` - Run pre-commit checks
