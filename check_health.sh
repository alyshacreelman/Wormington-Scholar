#!/bin/bash

# Check if "app.py" is running
if ! pgrep -f "python.*app.py"; then
    # Discord webhook URL
    WEBHOOK_URL=sys.argv[1]

    # Message payload for Discord
    PAYLOAD='{
        "content": "Wormington Scholar has been squashed!"
    }'

    # Send notification to Discord using webhook
    curl -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
fi
