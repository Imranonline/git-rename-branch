#!/usr/bin/bash

# Check if the user has provided input
if [ $# -ne 3 ]; then
    echo $0: usage: rename-branch.sh REPO_URL OLD_BRANCH_NAME NEW_BRANCH_NAME GIT_TOKEN
    exit 1
fi

REPO_URL=$1
OLD_BRANCH_NAME=$2
NEW_BRANCH_NAME=$3
GIT_TOKEN=$4

REPO_NAME="$(echo $REPO_URL | cut -d '/' -f 5 | cut -d '.' -f 1  )"
ACCOUNT_NAME="$(echo $REPO_URL | cut -d '/' -f 4 | cut -d '.' -f 1)"

echo Repo Name is $REPO_NAME
echo Account Name is $ACCOUNT_NAME

echo "removing $REPO_NAME Repo if exists"

rm -rf $REPO_NAME

#clone the URL 
echo "Cloning... $REPO_NAME"
git clone $REPO_URL

cd $REPO_NAME

git status
git fetch -a

 for i in $(git branch -a |grep 'remotes' | awk -F/ '{print $3}' | grep -v 'HEAD ->');
 do 
 git checkout -b $i --track origin/$i;
 done


for BRANCH in `git branch | grep $OLD_BRANCH_NAME` ;
do
MODIFIED_BRANCH_NAME="${BRANCH/$OLD_BRANCH_NAME/$NEW_BRANCH_NAME}"
echo $MODIFIED_BRANCH_NAME 

git checkout $BRANCH

git branch -m $BRANCH $MODIFIED_BRANCH_NAME 
git status
git push -u origin $MODIFIED_BRANCH_NAME
# Setting up the New Branch as Default Branch
curl --location --request PATCH 'https://api.github.com/repos/'$ACCOUNT_NAME'/'$REPO_NAME'' \
--header 'Authorization: Basic '$GIT_TOKEN'' \
--header 'Content-Type: application/json' \
--data-raw '{"default_branch": "'$NEW_BRANCH_NAME'"}'

git push origin --delete $BRANCH
git remote set-head origin -a
done  
echo Complete
