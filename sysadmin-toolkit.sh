
#!/usr/bin/env bash

set -euo pipefail

readonly VERSION="1.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load library modules
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/health.sh"
source "$SCRIPT_DIR/lib/backup.sh"
source "$SCRIPT_DIR/lib/loganalyzer.sh"


usage() {
    cat << EOF
System Admin Toolkit v$VERSION

Usage:
    $0 [options] command [arguments]

Commands:
    health
        Show system health report.

    backup DIRECTORY
        Create a timestamped backup.

    list-backups
        List available backups.

    analyze LOGFILE
        Analyze a log file.

    search LOGFILE PATTERN
        Search a log file.

    timeline LOGFILE
        Show events per hour.

Options:
    -d PERCENT    Disk warning threshold (default: 80)
    -k NUMBER     Number of backups to keep (default: 5)
    -l FILE       Activity log file
    -h            Show this help message.

Examples:
    $0 health
    $0 backup /tmp/demo
    $0 analyze /tmp/demo/app.log
    $0 search /tmp/demo/app.log "error"
EOF
}


interactive_menu() {
    local choice

    while true; do
        echo
        echo "========================================"
        echo "        SYSTEM ADMIN TOOLKIT"
        echo "========================================"
        echo "1) System Health"
        echo "2) Create Backup"
        echo "3) List Backups"
        echo "4) Analyze Log"
        echo "5) Search Log"
        echo "6) Log Timeline"
        echo "7) Exit"
        echo

        read -rp "Choose an option: " choice

        case "$choice" in
            1)
                health_report
                ;;
            2)
                read -rp "Directory to backup: " source_dir
                backup_create "$source_dir"
                ;;
            3)
                backup_list
                ;;
            4)
                read -rp "Log file: " logfile
                log_summary "$logfile"
                ;;
            5)
                read -rp "Log file: " logfile
                read -rp "Search pattern: " pattern
                log_search "$logfile" "$pattern"
                ;;
            6)
                read -rp "Log file: " logfile
                log_timeline "$logfile"
                ;;
            7)
                echo "Goodbye!"
                break
                ;;
            *)
                echo "Invalid option."
                ;;
        esac
    done
}


main() {
    local disk_warn="${DISK_WARN_PCT:-80}"
    local keep="${BACKUP_KEEP:-5}"
    local log_file="${LOG_FILE:-$HOME/.sysadmin-toolkit.log}"

    while getopts ":d:k:l:h" opt; do
        case "$opt" in
            d)
                disk_warn="$OPTARG"
                ;;
            k)
                keep="$OPTARG"
                ;;
            l)
                log_file="$OPTARG"
                ;;
            h)
                usage
                return 0
                ;;
            :)
                die "Option -$OPTARG requires an argument."
                ;;
            \?)
                die "Unknown option: -$OPTARG"
                ;;
        esac
    done

    shift $((OPTIND - 1))

    export DISK_WARN_PCT="$disk_warn"
    export BACKUP_KEEP="$keep"
    export LOG_FILE="$log_file"

    # No command = interactive menu
    if (( $# == 0 )); then
        interactive_menu
        return 0
    fi

    # Command dispatch
    case "$1" in
        health)
            health_report
            ;;

        backup)
            [[ $# -ge 2 ]] || die "Usage: $0 backup DIRECTORY"
            backup_create "$2"
            ;;

        list-backups)
            backup_list
            ;;

        analyze)
            [[ $# -ge 2 ]] || die "Usage: $0 analyze LOGFILE"
            log_summary "$2"
            ;;

        search)
            [[ $# -ge 3 ]] || die "Usage: $0 search LOGFILE PATTERN"
            log_search "$2" "$3"
            ;;

        timeline)
            [[ $# -ge 2 ]] || die "Usage: $0 timeline LOGFILE"
            log_timeline "$2"
            ;;

        -h|--help)
            usage
            ;;

        *)
            die "Unknown command: $1. Use -h for help."
            ;;
    esac
}


main "$@"