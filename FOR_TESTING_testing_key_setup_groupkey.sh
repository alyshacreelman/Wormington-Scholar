#!/bin/bash
# This script incorrectly tries to get the model running and esentially "kills" Wormington. It was run by us when we wanted to test our check_health.sh file and mkae sure our key_setup.sh file successfully gets the model back up and running
PORT=22003
MACHINE=paffenroth-23.dyn.wpi.edu

# Clean up from previous runs
ssh-keygen -f "/home/amcreelman/.ssh/known_hosts" -R "[${MACHINE}]:${PORT}"
rm -rf tmp2

# Create a temporary directory
mkdir tmp2
cp wormington_keys/group_key* tmp2
cd tmp2

# Set permissions of the key and prepare the authorized_keys file
chmod 600 group_key*
cat group_key.pub > authorized_keys
chmod 600 authorized_keys

# Copy the authorized_keys file to the server
scp -i group_key -P ${PORT} -o StrictHostKeyChecking=no authorized_keys student-admin@${MACHINE}:~/.ssh/

# Add the key to the ssh-agent
eval "$(ssh-agent -s)"
ssh-add group_key

# Check the key file on the server
ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE} "cat ~/.ssh/authorized_keys"

# Clone or pull the latest code
git clone https://github.com/alyshacreelman/Wormington-Scholar || (cd Wormington-Scholar && git pull)

# Copy the files to the server
scp -P ${PORT} -o StrictHostKeyChecking=no -r Wormington-Scholar student-admin@${MACHINE}:~/ 

COMMAND="ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE}"

# Stop the current chatbot instance
${COMMAND} "pkill -f app.py"

# Check that the code is updated
${COMMAND} "cat Wormington-Scholar/app.py | head -n 10"

# Setup and activate virtual environment
${COMMAND} "sudo apt install -qq -y python3-venv"
${COMMAND} "cd Wormington-Scholar && python3 -m venv venv"
${COMMAND} "cd Wormington-Scholar && source venv/bin/activate && pip install -r requirements.txt"

# Clear cache
${COMMAND} "find Wormington-Scholar/ -name '*.pyc' -delete"

# Start the chatbot
${COMMAND} "nohup Wormington-Scholar/venv/bin/python3 Wormington-Scholar/app.py > log.txt 2>&1 &"

# Check the last lines of the log
${COMMAND} "tail -n 20 log.txt"
