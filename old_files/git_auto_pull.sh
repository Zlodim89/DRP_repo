#!/bin/bash

cd /home/toor/repo || exit

echo "---- $(date) ----" >> git_pull.log

eval "$(ssh-agent -s)"
ssh-add /root/.ssh/git-key

git pull origin master >> git_pull.log 2>&1


