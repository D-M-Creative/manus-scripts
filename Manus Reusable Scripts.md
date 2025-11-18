# Manus Reusable Scripts

This repository contains reusable scripts for automated tasks and workflows in Manus.

## Scripts

### 1. stripeNotify.py

A Python script for sending notifications to Slack via incoming webhooks.

**Features:**
- Easy integration with any shell script or task
- Flexible configuration via environment variable or command-line argument
- Richly formatted messages with color-coded levels
- Notification levels: `info`, `success`, `warning`, and `error`
- Automatic timestamps

**Usage:**

```bash
# Set webhook URL as environment variable (recommended)
export SLACK_WEBHOOK_URL="your_slack_webhook_url_here"

# Send a basic notification
python3 stripeNotify.py --message "This is a test message."

# Send with custom title and level
python3 stripeNotify.py --title "Task Complete" --message "The data processing task finished successfully." --level success

# Send an error alert
python3 stripeNotify.py --title "Critical Alert" --message "The backup process failed." --level error
```

**Integration with scheduled tasks:**

```bash
# Notify on success or failure
/path/to/your/command && python3 stripeNotify.py --message "Task succeeded." --level success || python3 stripeNotify.py --message "Task failed." --level error
```

### 2. test_ribblesdale_form.sh

A bash script that tests the Ribblesdale Park wedding brochure form submission and automatically posts failures to ClickUp.

**Features:**
- Automated form testing using Playwright MCP
- Logs all test results to timestamped files
- Captures screenshots on failure
- Automatically creates high-priority ClickUp tasks when errors are detected
- Detects HTTP 4xx and 5xx errors

**Usage:**

```bash
./test_ribblesdale_form.sh
```

**Requirements:**
- Playwright MCP server configured and authenticated
- ClickUp MCP server configured and authenticated
- Access to the ClickUp list (ID: 34178263)

**Log Files:**
Test logs are stored in `/home/ubuntu/form_test_logs/` with timestamps.

## Setup for Scheduled Tasks

To use these scripts in Manus scheduled tasks, include the following in your task prompt:

```
Clone the scripts repository from GitHub:
gh repo clone dandmcreative/manus-scripts /home/ubuntu/manus-scripts

Then run the desired script...
```

## Configuration

### Slack Webhook URL

For `stripeNotify.py`, set your Slack webhook URL as an environment variable:

```bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

You can create a Slack incoming webhook by:
1. Going to your Slack workspace settings
2. Navigate to "Apps" → "Incoming Webhooks"
3. Create a new webhook and select the channel for notifications
4. Copy the webhook URL

## Contributing

These scripts are maintained for use in Manus automated workflows. Feel free to modify them for your specific needs.

## License

MIT License - Feel free to use and modify these scripts as needed.
