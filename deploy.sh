#!/bin/bash

set -e 

if [ $# -lt 1 ]; then
  echo "$0 <commit message>"
  exit 1
fi

msg="$1"
git commit -m "$msg"

if [ $? -ne 0 ]; then
  echo "Commit failed."
  exit 1
fi

git push origin master

if [ $? -ne 0 ]; then 
  echo "Push failed"
fi

echo "Deploying github..."

hugo

cd public

git add .

git commit -m "$msg"

git push origin master 

cd ..
