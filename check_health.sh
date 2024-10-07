#!/bin/bash
# This is the actual check_health.sh file that we are submitting as the extra credit for case study 2
# Read the Discord webhook URL from the file passed as the first argument (keeping it on the computer and not pasting here for security purposes)
WEBHOOK_URL=$(cat "$1")

# We will be checking this URL which should have our product up and running
URL="http://paffenroth-23.dyn.wpi.edu:8003/"

# Check if the URL is up
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

# Run the key setup file to get Wormington back up and running
./Wormington-Scholar/key_setup.sh
