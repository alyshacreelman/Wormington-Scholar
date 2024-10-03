#!/bin/bash

# Check if a file was passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <webhook_file>"
    exit 1
fi

# Read the Discord webhook URL from the file passed as the first argument
WEBHOOK_URL=$(cat "$1")

# Check if "app.py" is running
if ! pgrep -f "python.*app.py"; then
    # Message payload for Discord
    PAYLOAD='{
        "content": "Wormington Scholar has been squashed!"
    }'

    # Send notification to Discord using webhook
    curl -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
fi
