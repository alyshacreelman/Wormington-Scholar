#! /bin/bash

# check that the code in installed and start up the product
COMMAND="ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE}"

${COMMAND} "ls Wormington-Scholar"
${COMMAND} "cd Wormington-Scholar"
${COMMAND} "git pull"
${COMMAND} "cd .."
${COMMAND} "sudo apt install -qq -y python3-venv"
${COMMAND} "cd Wormington-Scholar && python3 -m venv venv"
${COMMAND} "cd Wormington-Scholar && source venv/bin/activate && pip install -r requirements.txt"
${COMMAND} "nohup Wormington-Scholar/venv/bin/python3 Wormington-Scholar/app.py > log.txt 2>&1 &"

# nohup ./whatever > /dev/null 2>&1 
