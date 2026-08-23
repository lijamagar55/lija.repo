#!/usr/bin/env bash

# ==========================================
# Log Analyzer Functions
# ==========================================

log_summary() {
    local logfile="$1"

    if [[ ! -f "$logfile" ]]; then
        die "Log file does not exist: $logfile"
    fi

    echo
    echo "========================================"
    echo "             LOG SUMMARY"
    echo "========================================"

    echo
    echo "File: $logfile"
    echo "Total lines: $(wc -l < "$logfile")"

    echo
    echo "Log levels:"

    awk '
    {
        for (i = 1; i <= NF; i++) {
            if ($i == "INFO" ||
                $i == "WARN" ||
                $i == "WARNING" ||
                $i == "ERROR" ||
                $i == "DEBUG") {
                count[$i]++
            }
        }
    }

    END {
        for (level in count) {
            print level ": " count[level]
        }
    }
    ' "$logfile" | sort

    echo
    echo "Top error messages:"

    grep -i 'ERROR' "$logfile" |
        sed -E 's/^.*ERROR[[:space:]]+//' |
        sort |
        uniq -c |
        sort -nr |
        head -n 10
}


log_search() {
    local logfile="$1"
    local pattern="$2"

    if [[ ! -f "$logfile" ]]; then
        die "Log file does not exist: $logfile"
    fi

    grep -in -- "$pattern" "$logfile"
}


log_timeline() {
    local logfile="$1"

    if [[ ! -f "$logfile" ]]; then
        die "Log file does not exist: $logfile"
    fi

    echo
    echo "Events per hour:"

    awk '
    {
        hour = substr($2, 1, 2)

        if (hour ~ /^[0-9][0-9]$/) {
            count[hour]++
        }
    }

    END {
        for (hour in count) {
            printf "%s:00 - %s:59  %d events\n",
                   hour, hour, count[hour]
        }
    }
    ' "$logfile" | sort
}