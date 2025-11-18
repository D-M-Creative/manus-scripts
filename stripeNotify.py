#!/usr/bin/env python3
"""
stripeNotify.py - Reusable notification script for Slack
Sends notifications to Slack via webhook URL.

Usage:
    python3 stripeNotify.py --message "Your message here"
    python3 stripeNotify.py --message "Task failed" --title "Error Alert" --level error
    
Environment Variables:
    SLACK_WEBHOOK_URL - The Slack incoming webhook URL (required)
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error
from datetime import datetime


def send_slack_notification(webhook_url, message, title=None, level="info"):
    """
    Send a notification to Slack via webhook.
    
    Args:
        webhook_url (str): The Slack webhook URL
        message (str): The main message content
        title (str): Optional title for the notification
        level (str): Notification level (info, warning, error, success)
    
    Returns:
        bool: True if successful, False otherwise
    """
    # Color coding based on level
    colors = {
        "info": "#36a64f",      # green
        "success": "#2eb886",   # bright green
        "warning": "#ff9900",   # orange
        "error": "#ff0000"      # red
    }
    
    color = colors.get(level.lower(), colors["info"])
    
    # Build the Slack message payload
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Create attachment for rich formatting
    attachment = {
        "color": color,
        "fields": [
            {
                "title": title if title else f"Notification ({level.upper()})",
                "value": message,
                "short": False
            },
            {
                "title": "Timestamp",
                "value": timestamp,
                "short": True
            }
        ]
    }
    
    payload = {
        "attachments": [attachment]
    }
    
    # Send the request
    try:
        req = urllib.request.Request(
            webhook_url,
            data=json.dumps(payload).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )
        
        with urllib.request.urlopen(req, timeout=10) as response:
            if response.status == 200:
                return True
            else:
                print(f"Error: Slack API returned status {response.status}", file=sys.stderr)
                return False
                
    except urllib.error.HTTPError as e:
        print(f"HTTP Error: {e.code} - {e.reason}", file=sys.stderr)
        return False
    except urllib.error.URLError as e:
        print(f"URL Error: {e.reason}", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Unexpected error: {str(e)}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Send notifications to Slack via webhook"
    )
    parser.add_argument(
        "--message",
        required=True,
        help="The message content to send"
    )
    parser.add_argument(
        "--title",
        help="Optional title for the notification"
    )
    parser.add_argument(
        "--level",
        choices=["info", "success", "warning", "error"],
        default="info",
        help="Notification level (default: info)"
    )
    parser.add_argument(
        "--webhook-url",
        help="Slack webhook URL (can also be set via SLACK_WEBHOOK_URL env var)"
    )
    
    args = parser.parse_args()
    
    # Get webhook URL from argument or environment variable
    webhook_url = args.webhook_url or os.environ.get("SLACK_WEBHOOK_URL")
    
    if not webhook_url:
        print("Error: Slack webhook URL not provided.", file=sys.stderr)
        print("Set SLACK_WEBHOOK_URL environment variable or use --webhook-url argument.", file=sys.stderr)
        sys.exit(1)
    
    # Send the notification
    success = send_slack_notification(
        webhook_url=webhook_url,
        message=args.message,
        title=args.title,
        level=args.level
    )
    
    if success:
        print("Notification sent successfully")
        sys.exit(0)
    else:
        print("Failed to send notification", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
