#! /bin/bash

# Establishing what our port and machine are
PORT=22003
MACHINE=paffenroth-23.dyn.wpi.edu

# Clean up from previous runs (removing the directory we create in the next line)
ssh-keygen -f "/home/amcreelman/.ssh/known_hosts" -R "[${MACHINE}]:${PORT}"
rm -rf tmp2

# Create a temporary directory called tmp2 inside the current directory
mkdir tmp2

# Creating a variable for the HF TOKEN which can be found in a file inside the folder wormington_keys
HF_TOKEN=$(<wormington_keys/hf_token)

# Copy the student admin key (needed for initial login) to the temporary directory tmp2
cp wormington_keys/student-admin_key* tmp2

# Copy the group key to the temporary directory
cp wormington_keys/group_key* tmp2

# Change into the temporary directory
cd tmp2

# Set the permissions of the student admin key so it is not too open
chmod 600 student-admin_key*

# Set the permissions of the group key so it is not too open
chmod 600 group_key*

# skip creating unique key -- already have

# Insert the key into the authorized_keys file on the server
# One > creates (used this one to create the authorized_keys file with just the group key and no student admin)
cat group_key.pub > authorized_keys
# two >> appends
# Remove to lock down machine
#cat student-admin_key.pub >> authorized_keys

# Changing permissions of the authorized_keys file so that it is not too open
chmod 600 authorized_keys

echo "checking that the authorized_keys file is correct"
ls -l authorized_keys
cat authorized_keys

# Copy the authorized_keys file to the server
scp -i student-admin_key -P ${PORT} -o StrictHostKeyChecking=no authorized_keys student-admin@${MACHINE}:~/.ssh/

# Add the key to the ssh-agent
eval "$(ssh-agent -s)"
ssh-add group_key

# Entered our password

# Check the key file on the server
echo "checking that the authorized_keys file is correct"
ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE} "cat ~/.ssh/authorized_keys"

# Clone the repo locally
git clone https://github.com/alyshacreelman/Wormington-Scholar

# Copy the files to the server that we just got from the git clone
scp -P ${PORT} -o StrictHostKeyChecking=no -r Wormington-Scholar student-admin@${MACHINE}:~/

# Check that the code in installed and start up the product
COMMAND="ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE}"

# Kill the previous app.py as 
${COMMAND} "pkill -f app.py"

${COMMAND} "ls Wormington-Scholar"
# Creating a virtual environment named venv
${COMMAND} "sudo apt install -qq -y python3-venv"
${COMMAND} "cd Wormington-Scholar && python3 -m venv venv"
# activating and installing what is in requirements.txt
${COMMAND} "cd Wormington-Scholar && source venv/bin/activate && pip install -r requirements.txt"
# Running app.py and passing in the HF token so we can ask more than one question to the chatbot
${COMMAND} "nohup Wormington-Scholar/venv/bin/python3 Wormington-Scholar/app.py ${HF_TOKEN} > log.txt 2>&1 &"

# nohup ./whatever > /dev/null 2>&1 
