#!/bin/bash

# tidy_bot.sh - Automated Disk Cleanup Script

# Configuration
THRESHOLD=${THRESHOLD:-85}
DRY_RUN=${DRY_RUN:-false}
LOG_FILE="/var/log/tidy_bot.log"

# Function to log actions with timestamps
log_message() {
    local MESSAGE="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" | tee -a "$LOG_FILE"
}

# 1. Root Check: Ensure the script runs with sudo/root privileges
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root or with sudo."
   exit 1
fi

# Ensure log file exists and is writable
touch "$LOG_FILE" 2>/dev/null || { echo "Error: Cannot write to $LOG_FILE."; exit 1; }

# 2. Check Disk Usage: Get the current usage percentage of the root /
CURRENT_USAGE=$(df / | grep / | tail -1 | awk '{ print $5 }' | sed 's/%//')

if [ "$CURRENT_USAGE" -gt "$THRESHOLD" ]; then
    log_message "Disk usage is at ${CURRENT_USAGE}%. Threshold is ${THRESHOLD}%. Starting cleanup..."

    # A. Package Cache Cleanup
    if command -v apt-get &> /dev/null; then
        log_message "Detected Debian/Zorin system. Cleaning apt-get cache..."
        if [ "$DRY_RUN" = "true" ]; then
            echo "[DRY_RUN] Would execute: apt-get clean"
        else
            apt-get clean
        fi
    elif command -v pacman &> /dev/null; then
        log_message "Detected Archcraft/Arch system. Cleaning pacman cache..."
        if [ "$DRY_RUN" = "true" ]; then
            echo "[DRY_RUN] Would execute: pacman -Sc --noconfirm"
        else
            pacman -Sc --noconfirm
        fi
    fi

    # B. Old Logs (.gz or .1 older than 30 days)
    log_message "Searching for rotated logs (.gz, .1) older than 30 days in /var/log..."
    if [ "$DRY_RUN" = "true" ]; then
        find /var/log -type f \( -name "*.gz" -o -name "*.1" \) -mtime +30 -exec echo "[DRY_RUN] Would delete: {}" \;
    else
        find /var/log -type f \( -name "*.gz" -o -name "*.1" \) -mtime +30 -delete
    fi

    # C. Temp Files (not accessed in 7 days)
    log_message "Cleaning files in /tmp not accessed in 7 days..."
    if [ "$DRY_RUN" = "true" ]; then
        find /tmp -type f -atime +7 -exec echo "[DRY_RUN] Would delete: {}" \;
    else
        # Use 2>/dev/null to ignore files currently in use or protected
        find /tmp -type f -atime +7 -delete 2>/dev/null
    fi

    # D. Docker Prune
    if command -v docker &> /dev/null; then
        log_message "Docker detected. Pruning system (dangling images, containers, networks)..."
        if [ "$DRY_RUN" = "true" ]; then
            echo "[DRY_RUN] Would execute: docker system prune -f"
        else
            docker system prune -f
        fi
    fi

    # Final Status Check
    NEW_USAGE=$(df / | grep / | tail -1 | awk '{ print $5 }' | sed 's/%//')
    log_message "Cleanup complete. Disk usage reduced from ${CURRENT_USAGE}% to ${NEW_USAGE}%."

else
    log_message "Disk usage is healthy at ${CURRENT_USAGE}% (Threshold: ${THRESHOLD}%). No action required."
fi
