#!/usr/bin/env bash

# ==========================================
# Common functions for System Admin Toolkit
# ==========================================

# Colors
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    RESET=''
fi

# Activity log file
LOG_FILE="${LOG_FILE:-$HOME/.sysadmin-toolkit.log}"


# ==========================================
# Log an informational message
# ==========================================
log_info() {
    local message="$1"

    printf '%s [INFO] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$message" >> "$LOG_FILE"

    printf '%b[INFO]%b %s\n' \
        "$GREEN" "$RESET" "$message"
}


# ==========================================
# Log a warning message
# ==========================================
log_warn() {
    local message="$1"

    printf '%s [WARN] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$message" >> "$LOG_FILE"

    printf '%b[WARN]%b %s\n' \
        "$YELLOW" "$RESET" "$message" >&2
}


# ==========================================
# Log an error message
# ==========================================
log_error() {
    local message="$1"

    printf '%s [ERROR] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$message" >> "$LOG_FILE"

    printf '%b[ERROR]%b %s\n' \
        "$RED" "$RESET" "$message" >&2
}


# ==========================================
# Print an error and stop the program
# ==========================================
die() {
    local message="$1"

    log_error "$message"
    exit 1
}


# ==========================================
# Check whether a required command exists
# ==========================================
require_cmd() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        die "Required command not found: $command_name"
    fi
}