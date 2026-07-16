---
name: analyze-repository
description: Analyze project structure and codebase, then output results to a Markdown file. Use when the user asks to investigate a repository's tech stack, directory structure, or dependencies and save the findings to a Markdown report.
---

The user may specify the output filename (default: `repository-analysis.md`).

Check README.md, package.json, and other config files; understand the directory structure; identify the technologies used.

Organize the findings — technology stack, directory structure and roles, key dependencies, development environment setup — and write them to the output file in this format:

```markdown
# Repository Analysis Results

## Project Overview
- Project Name: [name]
- Description: [overview]
- Language: [primary language]
- Framework: [framework used]

## Directory Structure
- `src/` - [role]
- `public/` - [role]
- `docs/` - [role]

## Key Dependencies
### Production Dependencies
- [library name] - [version]

### Development Dependencies  
- [tool name] - [version]

## Configuration Files
- [config file name] - [purpose]

## Analysis Date
[execution datetime]
```
