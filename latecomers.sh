#!/bin/bash

# Define file paths
LOG_FILE="data/late_log.txt"
STUDENT_FILE="data/students.csv"

# Ensure data directory and log file exist
mkdir -p data
touch "$LOG_FILE"

# Get Student ID
student_id=$(dialog --title "Student Late Entry" --inputbox "Enter Student ID:" 8 40 3>&1 1>&2 2>&3)
if [[ -z "$student_id" ]]; then
    dialog --msgbox "Cancelled. No entry recorded." 6 40
    clear
    exit 1
fi

# Validate Student ID from students.csv
student_info=$(grep "^$student_id," "$STUDENT_FILE")
if [[ -z "$student_info" ]]; then
    dialog --msgbox "Error: Student ID not found. Please contact your teacher." 6 50
    clear
    exit 1
fi

# Extract Student Name and Class
student_name=$(echo "$student_info" | cut -d',' -f2)
student_class=$(echo "$student_info" | cut -d',' -f3)

# Optional: Restrict to class 10A
if [[ "$student_class" != "10A" ]]; then
    dialog --msgbox "Access Denied: You are not part of class 10A." 6 50
    clear
    exit 1
fi

# Get Reason (Optional)
reason=$(dialog --title "Student Late Entry" --inputbox "Enter Reason (Optional):" 8 40 3>&1 1>&2 2>&3)

# Get current date and time
date_time=$(date '+%Y-%m-%d %H:%M:%S')

# Append entry with proper spacing
printf "%-10s | %-15s | %-10s | %-20s | %-30s\n" "$student_id" "$student_name" "$student_class" "$date_time" "$reason" >> "$LOG_FILE"

# Success message
dialog --msgbox "Late entry recorded successfully!" 6 40

# Clean and display log file
sed -i '/| $/d' "$LOG_FILE"
sed -i '/Can.t make sub-window/d' "$LOG_FILE"

# Display log in formatted manner
dialog --title "Recorded Entries" --textbox "$LOG_FILE" 15 80
