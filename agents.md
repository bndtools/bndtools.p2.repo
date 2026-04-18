# Agents for bndtools.p2.repo

This document describes the agents (automation, bots, or scripts) relevant to the bndtools.p2.repo project.

## Purpose
Agents are automated tools or scripts that help with repository maintenance, CI/CD, code quality, or other repetitive tasks.

## Agent Types
- **CI/CD Agents**: Automate build, test, and deployment (e.g., GitHub Actions, Jenkins).
- **Release Agents**: Handle versioning, changelog generation, and publishing artifacts.
- **Lint/Test Agents**: Run static analysis, code formatting, or automated tests.
- **Documentation Agents**: Generate or validate documentation (e.g., content2html.xsl, human-readable-index.sh in `processing/`).

## Project-Specific Agents
- **Shell Scripts**: Found in `processing/` and `doc/images/`, e.g., `convert.sh`, `human-readable-index.sh`.
- **XSLT Processing**: `content2html.xsl` for transforming XML content to HTML.
- **Ruby Plugins**: Custom Jekyll plugins in `site/_plugins/` (e.g., `git_info.rb`).

## Adding or Modifying Agents
- Place new scripts in the appropriate directory (`processing/`, `doc/images/`, etc.).
- Document the agent's purpose and usage in this file.
- Ensure agents are executable and, if needed, referenced in CI/CD workflows.

## Maintenance
- Review agents regularly for relevance and security.
- Update this file when agents are added, removed, or changed.
