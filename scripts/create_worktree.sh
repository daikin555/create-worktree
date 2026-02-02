#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Usage
usage() {
    echo "Usage: $0 <feature-name>"
    echo ""
    echo "Creates a git worktree for parallel feature development."
    echo ""
    echo "Arguments:"
    echo "  feature-name    Name of the feature (e.g., user-auth, dashboard-redesign)"
    echo ""
    echo "Example:"
    echo "  $0 user-auth"
    echo ""
    echo "This will create:"
    echo "  - Branch: feature/user-auth"
    echo "  - Worktree: .worktrees/user-auth/"
    echo ""
    echo "Configuration:"
    echo "  Place a .worktree.conf file in the repository root to customize behavior."
    echo "  See .worktree.conf.example for details."
    exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
    log_error "Feature name is required"
    usage
fi

FEATURE_NAME="$1"
BRANCH_NAME="feature/${FEATURE_NAME}"
WORKTREE_DIR=".worktrees/${FEATURE_NAME}"

# Get the root directory of the repository
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

log_info "Creating worktree for feature: ${FEATURE_NAME}"
log_info "Branch: ${BRANCH_NAME}"
log_info "Worktree directory: ${WORKTREE_DIR}"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    log_error "Not a git repository"
    exit 1
fi

# Check if worktree already exists
if [ -d "${WORKTREE_DIR}" ]; then
    log_error "Worktree already exists: ${WORKTREE_DIR}"
    log_info "To remove it, run: git worktree remove ${WORKTREE_DIR}"
    exit 1
fi

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
    log_warn "Branch ${BRANCH_NAME} already exists"
    log_info "Creating worktree from existing branch..."
    git worktree add "${WORKTREE_DIR}" "${BRANCH_NAME}"
else
    log_step "Creating new branch and worktree..."
    git worktree add -b "${BRANCH_NAME}" "${WORKTREE_DIR}" main
fi

log_info "Worktree created successfully"

# Load configuration
ENV_FILES=()
PORT_VARS=()
SETUP_COMMAND=""

CONF_FILE="${REPO_ROOT}/.worktree.conf"
if [ -f "${CONF_FILE}" ]; then
    log_info "Loading configuration from .worktree.conf"
    # shellcheck source=/dev/null
    source "${CONF_FILE}"
else
    log_info "No .worktree.conf found, using defaults (.env and .envrc only)"
    ENV_FILES=(".env" ".envrc")
fi

# Copy environment files
log_step "Copying environment files..."

# Function to copy file if it exists
copy_if_exists() {
    local src="$1"
    local dest="$2"
    local dest_dir
    dest_dir=$(dirname "${dest}")
    if [ -f "${src}" ]; then
        mkdir -p "${dest_dir}"
        cp "${src}" "${dest}"
        log_info "Copied: ${src}"
    fi
}

# Function to generate random port (range: 10000-60000)
generate_random_port() {
    echo $((RANDOM % 50000 + 10000))
}

# Copy environment files
for env_file in "${ENV_FILES[@]}"; do
    if [ "${env_file}" = ".env" ] && [ ${#PORT_VARS[@]} -gt 0 ] && [ -f "${env_file}" ]; then
        # Root .env with port randomization
        log_info "Copying .env with randomized ports:"
        sed_args=()
        for var in "${PORT_VARS[@]}"; do
            random_port=$(generate_random_port)
            sed_args+=(-e "s/^${var}=.*/${var}=${random_port}/")
            log_info "  ${var}=${random_port}"
        done
        sed "${sed_args[@]}" "${env_file}" > "${WORKTREE_DIR}/${env_file}"
    else
        copy_if_exists "${env_file}" "${WORKTREE_DIR}/${env_file}"
    fi
done

log_info "Environment files copied"

# Run setup command if configured
if [ -n "${SETUP_COMMAND}" ]; then
    log_step "Running setup command: ${SETUP_COMMAND}"
    cd "${WORKTREE_DIR}"
    eval "${SETUP_COMMAND}" || log_warn "Setup command completed with warnings"
    log_info "Setup completed"
else
    log_info "No setup command configured, skipping setup"
fi

# Print summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Worktree created successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Location: ${REPO_ROOT}/${WORKTREE_DIR}"
echo "Branch:   ${BRANCH_NAME}"
echo ""
echo "To start working:"
echo "  cd ${WORKTREE_DIR}"
echo ""
echo "To remove worktree when done:"
echo "  git worktree remove ${WORKTREE_DIR}"
echo ""
