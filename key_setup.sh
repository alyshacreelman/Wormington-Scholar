#! /bin/bash

PORT=22003
MACHINE=paffenroth-23.dyn.wpi.edu

# Clean up from previous runs
ssh-keygen -f "/home/amcreelman/.ssh/known_hosts" -R "[${MACHINE}]:${PORT}"
rm -rf tmp2

# Create a temporary directory
mkdir tmp2

# copy the key to the temporary directory
cp wormington_keys/student-admin_key* tmp2

# copy the key to the temporary directory
cp wormington_keys/group_key* tmp2

# Change to the temporary directory
cd tmp2

# Set the permissions of the key
chmod 600 student-admin_key*

# Set the permissions of the key
chmod 600 group_key*

# skip creating unique key -- already have

# Insert the key into the authorized_keys file on the server
# One > creates
cat group_key.pub > authorized_keys
# two >> appends
# Remove to lock down machine
#cat student-admin_key.pub >> authorized_keys

chmod 600 authorized_keys

echo "checking that the authorized_keys file is correct"
ls -l authorized_keys
cat authorized_keys

# Copy the authorized_keys file to the server
scp -i student-admin_key -P ${PORT} -o StrictHostKeyChecking=no authorized_keys student-admin@${MACHINE}:~/.ssh/

# Add the key to the ssh-agent
eval "$(ssh-agent -s)"
ssh-add group_key

# entered our password

# Check the key file on the server
echo "checking that the authorized_keys file is correct"
ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE} "cat ~/.ssh/authorized_keys"

# clone the repo
git clone https://github.com/alyshacreelman/Wormington-Scholar

# Copy the files to the server
scp -P ${PORT} -o StrictHostKeyChecking=no -r Wormington-Scholar student-admin@${MACHINE}:~/

# from here on code is currently commented out in Randy's code

# check that the code in installed and start up the product
COMMAND="ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE}"

${COMMAND} "ls Wormington-Scholar"
${COMMAND} "sudo apt install -qq -y python3-venv"
${COMMAND} "cd Wormington-Scholar && python3 -m venv venv"
${COMMAND} "cd Wormington-Scholar && source venv/bin/activate && pip install -r requirements.txt"
${COMMAND} "nohup Wormington-Scholar/venv/bin/python3 Wormington-Scholar/app.py > log.txt 2>&1 &"

# nohup ./whatever > /dev/null 2>&1 
