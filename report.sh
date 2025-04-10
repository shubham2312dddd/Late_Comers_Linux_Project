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
        REPORT=$(awk -F ' *\\| *' -v today="$TODAY" '$4 ~ today' "$LOG_FILE")
        ;;
    2)  # Weekly Report
        REPORT=$(awk -F ' *\\| *' -v start="$LAST_7_DAYS" -v end="$TODAY" '$4 >= start && $4 <= end' "$LOG_FILE")
        ;;
    3)  # Monthly Report
        REPORT=$(awk -F ' *\\| *' -v start="$LAST_30_DAYS" -v end="$TODAY" '$4 >= start && $4 <= end' "$LOG_FILE")
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
    FORMATTED_REPORT="========================================\n  🏫 Latecomers Report\n========================================\nID        | Name            | Date-Time          | Reason\n--------------------------------------------------------------------------------"
    
    while IFS="|" read -r id name class date_time reason; do
        FORMATTED_REPORT+=$(printf "\n%-8s | %-15s | %-19s | %-30s" "$id" "$name" "$date_time" "$reason")
    done <<< "$REPORT"

    echo -e "$FORMATTED_REPORT" > temp_report.txt
    dialog --title "📊 Latecomers Report" --textbox temp_report.txt 20 80
    rm temp_report.txt
fi

clear
