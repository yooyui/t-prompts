# Project Initializer Command

Initialize a new project with the specified template.

## Instructions

1. Parse the project type from: `$ARGUMENTS`
2. Load the project-templates module from `claude-prompts/12-project-templates.md`
3. Apply the corresponding template based on project type

Supported project types:
- `react-app` - React application with TypeScript
- `node-api` - Node.js REST API
- `python-cli` - Python CLI tool
- `typescript-lib` - TypeScript library

4. Create the project structure according to the template
5. Initialize dev-logs system if applicable

Example usage:
- `/init react-app` - Initialize a React app project
- `/init node-api` - Initialize a Node.js API project
