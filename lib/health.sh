#!/usr/bin/env bash

# ==========================================
# System Health Functions
# ==========================================

health_report() {
    local uptime_info
    local load_info
    local memory_info
    local disk_info

    echo
    echo "========================================"
    echo "        SYSTEM HEALTH REPORT"
    echo "========================================"

    echo
    echo "Uptime:"
    uptime

    echo
    echo "Load Average:"
    load_info="$(awk '{print $1, $2, $3}' /proc/loadavg)"
    echo "$load_info"

    echo
    echo "Memory Usage:"
    free -h

    echo
    echo "Disk Usage:"
    df -h --output=target,pcent,avail |
        awk '
        NR == 1 {
            print
            next
        }

        {
            gsub("%", "", $2)

            if ($2 >= ENVIRON["DISK_WARN_PCT"]) {
                printf "%-30s %3s%%  WARNING\n", $1, $2
            } else {
                printf "%-30s %3s%%\n", $1, $2
            }
        }
        '

    echo
    echo "Top 5 Memory-Hungry Processes:"
    ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 6
}