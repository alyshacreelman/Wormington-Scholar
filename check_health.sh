#!/bin/bash

# Read the Discord webhook URL from the file passed as the first argument
WEBHOOK_URL=$(cat "$1")

# The URL to check
URL="http://paffenroth-23.dyn.wpi.edu:8003/"

# Check if the URL is up (HTTP status 200-299 means success)
if curl -s --head "$URL" | grep "HTTP/[1-2].[0-9] [2][0-9][0-9]" > /dev/null; then
    # Message payload for Discord (healthy)
    PAYLOAD=$(cat <<EOF
{
    "content": "Wormington Scholar is healthy!"
}
EOF
)
else
    # Message payload for Discord (site down)
    PAYLOAD=$(cat <<EOF
{
    "content": "Wormington Scholar has been squashed!"
}
EOF
)
fi

# Send notification to Discord using the webhook
curl -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"

./Wormington-Scholar/key_setup.sh
