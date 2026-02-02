# Worktree Creator - Reference

## What is Git Worktree?

Git worktree allows you to **check out multiple branches simultaneously** within the same repository.

### Example Directory Structure

```
project/                      # main worktree (main branch)
├── .worktrees/
│   ├── user-auth/             # feature/user-auth branch
│   └── dashboard-redesign/    # feature/dashboard-redesign branch
```

## Common Use Cases

### 1. Parallel Feature Development

When multiple features are planned in plan mode, each can be developed in parallel using separate worktrees.

```bash
# Worktree for feature A
bash .claude/skills/create-worktree/scripts/create_worktree.sh feature-a

# Worktree for feature B (in a separate terminal)
bash .claude/skills/create-worktree/scripts/create_worktree.sh feature-b
```

### 2. Hotfixes

Apply urgent fixes without interrupting main development.

```bash
bash .claude/skills/create-worktree/scripts/create_worktree.sh hotfix-critical-bug
```

### 3. PR Reviews

Review other PRs without interrupting your current work.

```bash
git worktree add .worktrees/review-pr-123 origin/feature/some-pr
```

## Configuration

The script reads settings from `.worktree.conf` in the repository root. If no configuration file is found, only `.env` and `.envrc` are copied.

### `.worktree.conf` Format

```bash
# Environment files to copy (one path per entry, relative to repo root)
ENV_FILES=(
  ".env"
  ".envrc"
  "services/api/.env"
)

# Port variable names to randomize in .env
PORT_VARS=(
  "PORT"
  "API_PORT"
)

# Setup command (empty string to skip)
SETUP_COMMAND="make setup"
```

See `.worktree.conf.example` for a full template.

## Git Worktree Command Reference

### List Worktrees

```bash
git worktree list
```

### Add Worktree (Existing Branch)

```bash
git worktree add <path> <branch>
```

### Add Worktree (New Branch)

```bash
git worktree add -b <new-branch> <path> <start-point>
```

### Remove Worktree

```bash
git worktree remove <worktree-path>
```

### Repair Worktree (Recover from Locked State)

```bash
git worktree repair
```

### Force Remove (With Uncommitted Changes)

```bash
git worktree remove --force <worktree-path>
```

## Troubleshooting

### Worktree Already Exists

```bash
# Check status
git worktree list

# Remove
git worktree remove .worktrees/<feature-name>

# Force remove
rm -rf .worktrees/<feature-name>
git worktree prune
```

### Forgot to Copy Environment Files

Re-run the script or manually copy files listed in your `.worktree.conf`:

```bash
# Manually copy from root
cp .env .worktrees/<feature-name>/
```

### Branch Already Exists

The script will use the existing branch to create the worktree.
To create a new branch, delete the existing one first.

```bash
git branch -d feature/<feature-name>
```

### Worktree is Locked

```bash
git worktree unlock .worktrees/<feature-name>
```

## Best Practices

### 1. Naming Conventions

- Features: `feature-<name>`
- Bug fixes: `fix-<name>`
- Hotfixes: `hotfix-<name>`
- Refactoring: `refactor-<name>`

### 2. Cleanup After Completion

After a PR is merged, remove the worktree and branch:

```bash
# Remove worktree
git worktree remove .worktrees/<feature-name>

# Delete branch (if already deleted on remote)
git branch -d feature/<feature-name>
```

### 3. Regular Pruning

Remove stale worktree references:

```bash
git worktree prune
```

## Related Documentation

- [Git Worktree Official Documentation](https://git-scm.com/docs/git-worktree)
