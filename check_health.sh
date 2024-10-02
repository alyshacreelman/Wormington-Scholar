#!/bin/bash

# Check if "app.py" is running
if ! pgrep -f "python.*app.py"; then
    echo "Wormington Scholar has been squashed!" | mail -s "Wormington Down Alert" amcreelman@wpi.edu,eesojka@wpi.edu,jekimball@wpi.edu
fi
