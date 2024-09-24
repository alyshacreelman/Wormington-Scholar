#! /bin/bash

PORT=22003
MACHINE=paffenroth-23.dyn.wpi.edu

# login using student-admin key
ssh -i student_admin -p {PORT} student-admin@{MACHINE}

# move directories
cd .ssh

# open the authorized_keys file
nano authorized_keys

# add our key to the authorized_keys file
cat my_key2.pub > authorized_keys

#change permissions on the keys
chmod 600 authorized_keys

echo "checking that the authorized_keys file is correct"
ls -l authorized_keys
cat authorized_keys

#WANT TO PUT A CHECK ON THE PERMISSIONS
