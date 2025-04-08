#!/bin/bash

# Define log file
LOG_FILE="data/late_log.txt"
mkdir -p data
touch "$LOG_FILE"

# Get Student ID
student_id=$(dialog --title "Student Late Entry" --inputbox "Enter Student ID:" 8 40 3>&1 1>&2 2>&3)
if [[ -z "$student_id" ]]; then
    dialog --msgbox "Cancelled. No entry recorded." 6 40
    clear
    exit 1
fi

# Get Student Name
student_name=$(dialog --title "Student Late Entry" --inputbox "Enter Student Name:" 8 40 3>&1 1>&2 2>&3)
if [[ -z "$student_name" ]]; then
    dialog --msgbox "Cancelled. No entry recorded." 6 40
    clear
    exit 1
fi

# Get Reason
reason=$(dialog --title "Student Late Entry" --inputbox "Enter Reason (Optional):" 8 40 3>&1 1>&2 2>&3)

# Get current date and time
date_time=$(date '+%Y-%m-%d %H:%M:%S')

# Append entry with proper spacing
printf "%-10s | %-15s | %-20s | %-30s\n" "$student_id" "$student_name" "$date_time" "$reason" >> "$LOG_FILE"

# Success message
dialog --msgbox "Late entry recorded successfully!" 6 40

# Clean and display log file
sed -i '/| $/d' "$LOG_FILE"
sed -i '/Can.t make sub-window/d' "$LOG_FILE"

# Display log in formatted manner
dialog --title "Recorded Entries" --textbox "$LOG_FILE" 15 80

clear
