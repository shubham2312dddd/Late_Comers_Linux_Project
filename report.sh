#!/bin/bash

LOG_FILE="data/late_log.txt"

# Ensure log file exists
if [ ! -f "$LOG_FILE" ]; then
    dialog --title "❌ Error" --msgbox "No records found!" 6 40
    exit 1
fi

# Get user choice
CHOICE=$(dialog --title "📋 Latecomers Report" --menu "Choose Report Type:" 12 50 3 \
1 "📅 Daily Report (Today)" \
2 "📆 Weekly Report (Last 7 Days)" \
3 "🗓 Monthly Report (Last 30 Days)" 3>&1 1>&2 2>&3)

# Get current date
TODAY=$(date '+%Y-%m-%d')
LAST_7_DAYS=$(date -d "7 days ago" '+%Y-%m-%d')
LAST_30_DAYS=$(date -d "30 days ago" '+%Y-%m-%d')

# Generate report based on user selection
case $CHOICE in
    1)  # Daily Report
        REPORT=$(grep "$TODAY" "$LOG_FILE")
        ;;
    2)  # Weekly Report
        REPORT=$(awk -v start="$LAST_7_DAYS" -v end="$TODAY" -F " | " '$3 >= start && $3 <= end' "$LOG_FILE")
        ;;
    3)  # Monthly Report
        REPORT=$(awk -v start="$LAST_30_DAYS" -v end="$TODAY" -F " | " '$3 >= start && $3 <= end' "$LOG_FILE")
        ;;
    *)
        dialog --title "⚠ Invalid Selection" --msgbox "Please choose a valid option!" 6 40
        exit 1
        ;;
esac

# Format report output
if [ -z "$REPORT" ]; then
    dialog --title "📊 Report" --msgbox "No records found for the selected period!" 8 50
else
    FORMATTED_REPORT=$(echo -e "========================================\n  🏫 Latecomers Report\n========================================\nName             | Date       | Reason\n----------------------------------------")
    
    while IFS="|" read -r name date reason; do
        FORMATTED_REPORT+=$(printf "\n%-16s | %-10s | %-30s" "$name" "$date" "$reason")
    done <<< "$REPORT"

    dialog --title "📊 Latecomers Report" --msgbox "$FORMATTED_REPORT" 20 80
fi

clear
