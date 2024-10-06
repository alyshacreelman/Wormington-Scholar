#! /bin/bash

# move to tmp (used an absolute path so every group member could get there)
cd /tmp

# generate the key group_key which we will need to create a password for
ssh-keygen -f group_key -t ed25519
