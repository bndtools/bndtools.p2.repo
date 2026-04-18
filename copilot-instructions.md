# GitHub Copilot Instructions for bndtools.p2.repo

This file provides guidelines for using GitHub Copilot and Copilot Chat in this repository.

## General Guidelines
- Use Copilot to assist with shell scripts, XSLT, Ruby plugins, and documentation.
- Review Copilot suggestions for accuracy, especially for build, release, and documentation scripts.
- For project-specific conventions, see `agents.md` and the `processing/` and `site/_plugins/` directories.

## Best Practices
- Always review and test Copilot-generated code before committing.
- For shell scripts, ensure POSIX compatibility unless otherwise required.
- For XSLT, validate output with sample XML files.
- For Ruby plugins, follow Jekyll and Ruby best practices.
- Document any Copilot-generated automation in `agents.md`.

## Copilot Chat Usage
- Use Copilot Chat to:
  - Explain scripts or automation logic.
  - Suggest improvements to existing agents.
  - Generate documentation or usage examples.
- When asking Copilot to create or modify agents, specify the directory and purpose.

## Contribution
- Update this file with new Copilot usage patterns or repository-specific instructions.
