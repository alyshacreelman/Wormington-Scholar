#!/bin/bash

# Check if "app.py" is running
if ! pgrep -f "app.py"; then
    echo "Chatbot is down" | mail -s "Chatbot Down Alert" amcreelman@wpi.edu,eesojka@wpi.edu,jekimball@wpi.edu
fi
