#!/bin/bash

# File paths
LOG_FILE="data/late_log.txt"
WARN_FILE="data/warnings.txt"
STUDENT_CSV="data/students.csv"
mkdir -p data  # Ensure the data directory exists
touch "$LOG_FILE" "$WARN_FILE"  # Ensure log & warning files exist

# Function to log a late entry
log_late_entry() {
    while true; do
        student_id=$(dialog --title "📝 Student Late Entry" --inputbox "Enter Student ID:" 8 40 3>&1 1>&2 2>&3)
        [[ -z "$student_id" ]] && break  # Allow user to exit

        student_name=$(dialog --title "📝 Student Late Entry" --inputbox "Enter Student Name:" 8 40 3>&1 1>&2 2>&3)
        [[ -z "$student_name" ]] && break  # Allow user to exit

        date_time=$(date '+%Y-%m-%d %H:%M:%S')

        echo "$student_id | $student_name | $date_time" >> "$LOG_FILE"

        dialog --title "✅ Success" --msgbox "Late entry recorded successfully!" 6 40
        break
    done
}

# Function to generate a report
generate_report() {
    while true; do
        CHOICE=$(dialog --title "📊 Latecomers Report" --menu "Choose Report Type:" 15 50 6 \
            1 "📅 Daily Report (Today)" \
            2 "📆 Weekly Report (Last 7 Days)" \
            3 "📅 Monthly Report (Last 30 Days)" \
            4 "⚠️ View Warnings" \
            5 "🔙 Back to Main Menu" 3>&1 1>&2 2>&3)

        TODAY=$(date '+%Y-%m-%d')
        LAST_7_DAYS=$(date -d "7 days ago" '+%Y-%m-%d')
        LAST_30_DAYS=$(date -d "30 days ago" '+%Y-%m-%d')

        case $CHOICE in
            1) REPORT=$(grep "$TODAY" "$LOG_FILE") ;;
            2) REPORT=$(awk -F ' *\\| *' -v start="$LAST_7_DAYS" -v end="$TODAY" '$3 >= start && $3 <= end' "$LOG_FILE") ;;
            3) REPORT=$(awk -F ' *\\| *' -v start="$LAST_30_DAYS" -v end="$TODAY" '$3 >= start && $3 <= end' "$LOG_FILE") ;;
            4) REPORT=$(cat "$WARN_FILE")
               [[ -z "$REPORT" ]] && REPORT="No warnings issued yet." ;;
            5) break ;;  # Return to main menu
            *) dialog --title "❌ Invalid" --msgbox "Invalid selection! Please try again." 6 40; continue ;;
        esac

        [[ -z "$REPORT" ]] && REPORT="No records found for the selected period!"
        dialog --title "📜 Latecomers Report" --msgbox "$REPORT" 15 60
    done
}

# Function to check & issue warnings
check_warnings() {
    > "$WARN_FILE"  # Clear previous warnings
    LAST_7_DAYS=$(date -d "7 days ago" '+%Y-%m-%d')

    awk -F ' *\\| *' -v start="$LAST_7_DAYS" '$3 >= start {print $1 "|" $2}' "$LOG_FILE" | sort | uniq -c | while read count entry; do
        student_id=$(echo "$entry" | cut -d '|' -f1 | xargs)
        student_name=$(echo "$entry" | cut -d '|' -f2 | xargs)

        if (( count >= 3 )); then
            echo "$student_id | $student_name | ⚠️ WARNING: Late $count times in the last 7 days!" >> "$WARN_FILE"
        fi
    done

    dialog --title "⚠️ Warning System" --msgbox "Warnings updated successfully!" 6 40
}

# Function to send email (calls notify.sh)
send_email() {
    if [[ ! -f "$STUDENT_CSV" ]]; then
        dialog --title "❌ Error" --msgbox "Missing students.csv file! Cannot send emails." 6 50
        return
    fi

    bash notify.sh
}

# Main menu
while true; do
    CHOICE=$(dialog --title "📌 Class Latecomers Management" --menu "Choose an option:" 15 50 6 \
        1 "📝 Log Latecomer Entry" \
        2 "📊 Generate Report" \
        3 "⚠️ Check Warnings" \
        4 "📧 Send Email Notifications" \
        5 "🚪 Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) log_late_entry ;;
        2) generate_report ;;
        3) check_warnings ;;
        4) send_email ;;  # Calls notify.sh
        5) clear; exit ;;
        *) dialog --title "❌ Invalid" --msgbox "Invalid option! Please select again." 6 40 ;;
    esac
done
