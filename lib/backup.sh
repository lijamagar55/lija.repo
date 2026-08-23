#!/usr/bin/env bash
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups}"

# ==========================================
# Backup Functions
# ==========================================

backup_create() {
    local source_dir="$1"
    local timestamp
    local backup_name
    local backup_path
    local backup_dir

    [[ -d "$source_dir" ]] || die "Directory not found: $source_dir"

    backup_dir="${BACKUP_DIR:-$HOME/backups}"

    mkdir -p "$backup_dir"

    timestamp="$(date '+%Y%m%d_%H%M%S')"
    backup_name="$(basename "$source_dir")_${timestamp}.tar.gz"
    backup_path="$backup_dir/$backup_name"

    tar -czf "$backup_path" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"

    log_info "Backup created: $backup_path"

    echo "Backup created:"
    echo "$backup_path"

    backup_rotate
}

backup_rotate() {
    local keep="${BACKUP_KEEP:-5}"
    local backup_dir="${BACKUP_DIR:-$HOME/backups}"
    local files=()
    local file
    local count=0

    mapfile -t files < <(
        find "$backup_dir" -maxdepth 1 -type f -name "*.tar.gz" -printf "%T@ %p\n" |
        sort -nr |
        cut -d' ' -f2-
    )

    for file in "${files[@]}"; do
        ((++count))

        if (( count > keep )); then
            rm -f -- "$file"
            log_info "Removed old backup: $file"
        fi
    done
}




backup_list() {
    local backup_dir="${BACKUP_DIR:-$HOME/backups}"

    echo
    echo "Available backups:"
    echo "========================================"

    if [[ ! -d "$backup_dir" ]]; then
        echo "No backup directory found."
        return 0
    fi

    find "$backup_dir" -maxdepth 1 -type f -name '*.tar.gz' -printf '%TY-%Tm-%Td %TH:%TM  %f\n' |
        sort -r
}