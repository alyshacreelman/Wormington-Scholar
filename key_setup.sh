#! /bin/bash

PORT=22003
MACHINE=paffenroth-23.dyn.wpi.edu

# Clean up from previous runs
ssh-keygen -f "/home/amcreelman/.ssh/known_hosts" -R "[${MACHINE}]:${PORT}



# login using student-admin key
ssh -i student_admin -p ${PORT} student-admin@${MACHINE}

#copy the key to the tmp directory 



#possibly have to rm known_hosts in ssh at some point to prevent an error

# move directories
#cd .ssh

# open the authorized_keys file
less authorized_keys

# add our key to the authorized_keys file
cat my_key2.pub > authorized_keys

#change permissions on the keys
chmod 600 authorized_keys

echo "checking that the authorized_keys file is correct"
ls -l authorized_keys
cat authorized_keys

#WANT TO PUT A CHECK ON THE PERMISSIONS







#NOTES FROM RANDY'S DEMO: 

<<comment1 (this starts a block comment)
this block removes the old key (known-hosts) from the old machine
also it's called item potency and he thinks this should go at the botom (how this works without wiping the vm so we can't login I don't know)
ssh-keygen -f "/home/rcpaffenroth/.ssh/known_hosts" -R "[paffenroth-23.dyn.wpi.edu]:21003"
rm -rf tmp


constructing an authorized keys file locally and then checking it before copying it over
cat > says take this and erase it if it exists and then create it and add the file
cat >> says don't erase it just append this thing to it
the >> is for testing so that the other key will be in there and you don't brick your machine, but for the actual thing you want to use >

randy says we should put a pause in this, but I don't know how we check it if not just visually? and this is supposed to be automated?
he says put a "do you mean this you crazy person?"
echo "checking that the authorized_keys file is correct"
ls -l authorized_keys
cat authorized_keys

this line copies the authorized_keys file
he says it is not item potent and can't be rerun again?
scp -i student-admin_key -P ${PORT} -o StrictHostKeyChecking=no authorized_keys student-admin@${MACHINE}:~/.ssh/

ohhhhh so this block makes it so that you don't have to type the password for the key more than once 
you type it once and it adds the key to a database, that's why we're adding the private key
# Add the key to the ssh-agent
eval "$(ssh-agent -s)"
ssh-add mykey

he says this is dumb because it only checks it if it's right
# Check the key file on the server
echo "checking that the authorized_keys file is correct"
ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE} "cat ~/.ssh/authorized_keys"

Remaining Questions: 
1. Why does he bother copying over the student-admin key to the new directory and changing the permissions? 
2. How does the password thing really work here? Same thing with the pause - 
  if it's supposed to be completely automated where if the server goes down at 2 am we can get it back up, 
  then doesn't this require human intervention to type in the password or approve the authorized_keys? 
3. If we put the cleanup line at the end, it must just delete known_users, which is fine because we already know it works with that deleted? 



comment1 (this ends the block comment)















