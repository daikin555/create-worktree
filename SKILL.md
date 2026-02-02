---
name: create-worktree
description: Creates a git worktree for parallel feature development. Use after planning to prepare an isolated development environment with all necessary environment files. Always refer to this when performing additional branch operations.
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(cp:*), Bash(chmod:*), Bash(bash:*), Bash(make:*)
---

# Git Worktree Creator

Automatically creates an isolated worktree environment for feature development after exiting plan mode.

## Overview

This skill performs the following steps automatically:

1. Creates a worktree in `.worktrees/<feature-name>/`
2. Creates a new `feature/<feature-name>` branch
3. Copies environment files (configured via `.worktree.conf` or defaults to `.env` and `.envrc`)
4. Optionally randomizes port variables to avoid conflicts between worktrees
5. Optionally runs a setup command

## Usage

### Basic Usage

```bash
# Run the script
bash .claude/skills/create-worktree/scripts/create_worktree.sh <feature-name>

# Example: developing the user-auth feature
bash .claude/skills/create-worktree/scripts/create_worktree.sh user-auth
```

### Result

```
.worktrees/user-auth/     # worktree directory
├── .env                  # copied from root (ports randomized if configured)
├── .envrc                # copied from root
└── ...                   # additional env files as configured
```

## Configuration

Create a `.worktree.conf` file in the repository root to customize behavior. See `.worktree.conf.example` for a template.

### Configuration Options

| Option | Description |
|--------|-------------|
| `ENV_FILES` | Array of environment file paths to copy into the worktree |
| `PORT_VARS` | Array of port variable names to randomize in `.env` |
| `SETUP_COMMAND` | Command to run after worktree creation (empty to skip) |

### Default Behavior (without `.worktree.conf`)

- Copies `.env` and `.envrc` from the repository root
- No port randomization
- No setup command

## After Completing Work

### Removing the Worktree

Use the **worktree-cleanup** skill to automatically remove the worktree:

```bash
cd .worktrees/<feature-name>
bash ../../.claude/skills/worktree-cleanup/scripts/worktree_cleanup.sh
```

See the [worktree-cleanup skill](../worktree-cleanup/SKILL.md) for details.

### Manual Worktree Removal

```bash
git worktree remove .worktrees/<feature-name>
```

## Details

See [REFERENCE.md](REFERENCE.md) for more details.
