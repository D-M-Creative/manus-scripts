#!/bin/bash

# Ribblesdale Park Wedding Brochure Form Test
# This script tests the form submission and posts failures to ClickUp

LOG_FILE="/home/ubuntu/form_test_logs/test_$(date +%Y%m%d_%H%M%S).log"
mkdir -p /home/ubuntu/form_test_logs

echo "=== Form Test Started at $(date) ===" | tee -a "$LOG_FILE"

# Get tomorrow's date in the format DD/MM/YYYY
TOMORROW=$(date -d "tomorrow" +%d/%m/%Y)
echo "Using date: $TOMORROW" | tee -a "$LOG_FILE"

# Navigate to the form page
echo "Navigating to form page..." | tee -a "$LOG_FILE"
manus-mcp-cli tool call browser_navigate --server playwright --input "{\"url\": \"https://www.ribblesdalepark.com/weddings/brochure/\"}" >> "$LOG_FILE" 2>&1

# Wait for page to load
sleep 2

# Fill in the form fields
echo "Filling form fields..." | tee -a "$LOG_FILE"

# Get page snapshot to get current refs
SNAPSHOT=$(manus-mcp-cli tool call browser_snapshot --server playwright --input '{}' 2>&1)

# Fill Full Name
manus-mcp-cli tool call browser_run_code --server playwright --input '{"code": "await page.getByRole(\"textbox\", { name: \"Full Name *\" }).fill(\"Test User\");"}' >> "$LOG_FILE" 2>&1

# Fill Email
manus-mcp-cli tool call browser_run_code --server playwright --input '{"code": "await page.getByRole(\"textbox\", { name: \"Email Address * Email\" }).fill(\"test@example.com\");"}' >> "$LOG_FILE" 2>&1

# Fill Phone
manus-mcp-cli tool call browser_run_code --server playwright --input '{"code": "await page.getByRole(\"spinbutton\", { name: \"Phone Number *\" }).fill(\"01234567890\");"}' >> "$LOG_FILE" 2>&1

# Fill Day Guests
manus-mcp-cli tool call browser_run_code --server playwright --input '{"code": "await page.getByRole(\"spinbutton\", { name: \"No. of Day Guests *\" }).fill(\"0\");"}' >> "$LOG_FILE" 2>&1

# Fill Evening Guests
manus-mcp-cli tool call browser_run_code --server playwright --input '{"code": "await page.getByRole(\"spinbutton\", { name: \"No. of Evening Guests *\" }).fill(\"0\");"}' >> "$LOG_FILE" 2>&1

# Fill Wedding Date
manus-mcp-cli tool call browser_run_code --server playwright --input "{\"code\": \"await page.getByRole('textbox', { name: 'Preferred Wedding Date *' }).fill('$TOMORROW');\"}" >> "$LOG_FILE" 2>&1

# Fill Budget
manus-mcp-cli tool call browser_run_code --server playwright --input '{"code": "await page.getByRole(\"spinbutton\", { name: \"Approx Venue Budget *\" }).fill(\"10000\");"}' >> "$LOG_FILE" 2>&1

# Fill Message
manus-mcp-cli tool call browser_run_code --server playwright --input '{"code": "await page.getByRole(\"textbox\", { name: \"Message\" }).fill(\"form submission\");"}' >> "$LOG_FILE" 2>&1

echo "Form filled, submitting..." | tee -a "$LOG_FILE"

# Click submit button
manus-mcp-cli tool call browser_run_code --server playwright --input '{"code": "await page.getByRole(\"button\", { name: \"Download Brochure\" }).click();"}' >> "$LOG_FILE" 2>&1

# Wait for AJAX response
sleep 5

# Check network requests for errors
echo "Checking network requests..." | tee -a "$LOG_FILE"
NETWORK_LOG=$(manus-mcp-cli tool call browser_network_requests --server playwright --input '{}' 2>&1)
echo "$NETWORK_LOG" >> "$LOG_FILE"

# Check for 503 error in admin-ajax.php
if echo "$NETWORK_LOG" | grep -q "admin-ajax.php.*503"; then
    echo "ERROR: Form submission failed with 503 error" | tee -a "$LOG_FILE"
    
    # Take screenshot
    SCREENSHOT_PATH="/home/ubuntu/form_test_logs/failure_$(date +%Y%m%d_%H%M%S).png"
    manus-mcp-cli tool call browser_take_screenshot --server playwright --input "{\"filename\": \"$SCREENSHOT_PATH\"}" >> "$LOG_FILE" 2>&1
    
    # Post to ClickUp
    echo "Posting failure to ClickUp..." | tee -a "$LOG_FILE"
    
    TASK_DESCRIPTION="**Form Test Failed**

**URL:** https://www.ribblesdalepark.com/weddings/brochure/

**Error:** Form submission returned 503 Service Unavailable error

**Test Date:** $(date '+%Y-%m-%d %H:%M:%S')

**Details:**
- The form was filled with test data
- Submission triggered AJAX POST to /wp-admin/admin-ajax.php
- Server returned HTTP 503 error
- This indicates the server is unavailable or experiencing issues

**Log File:** $LOG_FILE"

    manus-mcp-cli tool call clickup_create_task --server clickup --input "{
        \"list_id\": \"34178263\",
        \"name\": \"Ribblesdale Form Test Failed - $(date '+%Y-%m-%d')\",
        \"markdown_description\": $(echo "$TASK_DESCRIPTION" | jq -Rs .),
        \"priority\": \"high\"
    }" >> "$LOG_FILE" 2>&1
    
    echo "Failure posted to ClickUp" | tee -a "$LOG_FILE"
    exit 1
else
    # Check for other error indicators
    if echo "$NETWORK_LOG" | grep -qE "admin-ajax.php.*[45][0-9]{2}"; then
        ERROR_CODE=$(echo "$NETWORK_LOG" | grep -oP "admin-ajax.php.*\[\K[45][0-9]{2}" | head -1)
        echo "ERROR: Form submission failed with $ERROR_CODE error" | tee -a "$LOG_FILE"
        
        # Take screenshot
        SCREENSHOT_PATH="/home/ubuntu/form_test_logs/failure_$(date +%Y%m%d_%H%M%S).png"
        manus-mcp-cli tool call browser_take_screenshot --server playwright --input "{\"filename\": \"$SCREENSHOT_PATH\"}" >> "$LOG_FILE" 2>&1
        
        # Post to ClickUp
        echo "Posting failure to ClickUp..." | tee -a "$LOG_FILE"
        
        TASK_DESCRIPTION="**Form Test Failed**

**URL:** https://www.ribblesdalepark.com/weddings/brochure/

**Error:** Form submission returned $ERROR_CODE error

**Test Date:** $(date '+%Y-%m-%d %H:%M:%S')

**Details:**
- The form was filled with test data
- Submission triggered AJAX POST to /wp-admin/admin-ajax.php
- Server returned HTTP $ERROR_CODE error

**Log File:** $LOG_FILE"

        manus-mcp-cli tool call clickup_create_task --server clickup --input "{
            \"list_id\": \"34178263\",
            \"name\": \"Ribblesdale Form Test Failed - $(date '+%Y-%m-%d')\",
            \"markdown_description\": $(echo "$TASK_DESCRIPTION" | jq -Rs .),
            \"priority\": \"high\"
        }" >> "$LOG_FILE" 2>&1
        
        echo "Failure posted to ClickUp" | tee -a "$LOG_FILE"
        exit 1
    else
        echo "SUCCESS: Form submission completed without errors" | tee -a "$LOG_FILE"
        exit 0
    fi
fi

echo "=== Form Test Completed at $(date) ===" | tee -a "$LOG_FILE"
