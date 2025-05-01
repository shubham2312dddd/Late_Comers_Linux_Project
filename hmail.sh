#!/bin/bash

# Sender email (Fixed)
SENDER_EMAIL="shubhamhr2004@gmail.com"

# Load password securely (Ensure it's exported before running)
if [[ -z "$EMAIL_PASS" ]]; then
    echo "❌ Error: Email password not set. Export EMAIL_PASS first."
    exit 1
fi

# File paths
WARNING_FILE="data/warnings.txt"
STUDENT_CSV="data/students.csv"

# Ensure required files exist
if [[ ! -f "$WARNING_FILE" || ! -f "$STUDENT_CSV" ]]; then
    echo "❌ Error: Missing required files (warnings.txt or students.csv)."
    exit 1
fi

# Loop through warning records
while IFS='|' read -r student_id _; do
    # Trim spaces
    student_id=$(echo "$student_id" | xargs)

    # Skip empty lines
    [[ -z "$student_id" ]] && continue

    # Find student info from students.csv
    student_info=$(grep "^$student_id," "$STUDENT_CSV")

    if [[ -z "$student_info" ]]; then
        echo "⚠️  Student ID $student_id not found in CSV. Skipping..."
        continue
    fi

# Extract parent email from 4th column (and clean \r if any)
parent_email=$(echo "$student_info" | cut -d',' -f4 | tr -d '\r' | xargs)

# Extract student name from 2nd column
student_name=$(echo "$student_info" | cut -d',' -f2 | tr -d '\r' | xargs)


    # Check if email is valid
    if [[ "$parent_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        SUBJECT="Latecomer Warning Alert for $student_name"
        BODY="Dear Parent,\n\nWe noticed that $student_name (Student ID: $student_id) has been late multiple times recently.\nPlease encourage better punctuality.\n\nBest Regards,\nSchool Administration"

        # Create temporary email file
        EMAIL_FILE=$(mktemp)
        {
            echo "Subject: $SUBJECT"
            echo "From: $SENDER_EMAIL"
            echo "To: $parent_email"
            echo -e "\n$BODY"
        } > "$EMAIL_FILE"

        # Send email using msmtp
        echo "📧 Sending email to $parent_email..."
        msmtp --user="$SENDER_EMAIL" --passwordeval="echo $EMAIL_PASS" -t < "$EMAIL_FILE"

        if [[ $? -eq 0 ]]; then
            echo "✅ Email sent successfully to $parent_email!"
        else
            echo "❌ Failed to send email to $parent_email!"
        fi

        # Cleanup
        rm "$EMAIL_FILE"

    else
        echo "❌ Invalid email address for Student ID $student_id: $parent_email"
    fi

done < "$WARNING_FILE"

echo "✅ All notifications processed!"
