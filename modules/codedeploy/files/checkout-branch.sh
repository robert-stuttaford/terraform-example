#!/bin/bash -ex

BRANCH=$1
PROJECT=$2
DIRECTORY=$3

if git ls-remote git@github.com:Cognician/${PROJECT}.git  2>/dev/null |egrep "refs/heads/${BRANCH}$"
then
    echo "Checking out branch $BRANCH of $PROJECT"
else
    BRANCH="master"
    echo "Checking out branch $BRANCH of $PROJECT"
fi

if [ -z "$DIRECTORY" ]
then
    DIRECTORY=$PROJECT
fi

git clone git@github.com:Cognician/${PROJECT}.git ${DIRECTORY} --depth 1 --branch $BRANCH

exit 0
