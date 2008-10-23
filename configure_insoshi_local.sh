#!/bin/sh

# Automatic configuration for local Insoshi Git repository
#
# Requirements:
# 1. Working git installation
# 2. Fork of insoshi repository on GitHub
# 
# Usage:
# configure_insoshi_local [GitHub Account Name]
#
# This script will create a local clone of the official Insoshi Git
# repository located on GitHub.  The specified Insoshi fork will be
# added as an addtional remote repository and a new branch created to
# track local development.
#

# Verify number of arguments to script
#
if [ $# -ne "1" ]
then
  echo "Usage: configure_insoshi_local [GitHub Account Name]"
  exit 1
fi

GITHUB_ACCOUNT=`echo $1`

MAIN_REPOSITORY=`echo git://github.com/insoshi/insoshi.git`

REMOTE=`echo $GITHUB_ACCOUNT`
REMOTE_URL=`echo git@github.com:$GITHUB_ACCOUNT/insoshi.git`

BRANCH=`echo $GITHUB_ACCOUNT`

# Error handling function
catch_error() {
  if [ $1 -ne "0" ]
  then
    echo "ERROR encountered $2"
    exit 1
  fi
}

# Clone official insoshi repository
#
# This sets the local master branch to be equal to the official insoshi
# master
#
echo "Cloning official insoshi repository..."
git clone $MAIN_REPOSITORY
catch_error $? "cloning official insoshi repository"

echo

# Change directory into local insoshi repository
#
cd insoshi

# Create a local branch that tracks the forked master branch
#
echo "Creating local tracking branch for edge..."
git branch --track edge origin/edge
catch_error $? "creating local tracking branch for edge"

# Create a local branch based off edge
#
echo "Creating local branch $BRANCH..."
git branch $BRANCH edge
catch_error $? "creating local branch $BRANCH"

git checkout $BRANCH
catch_error $? "checking out local branch $BRANCH"

echo

# Add forked repository as a remote repository connection
#
# The GitHub account name will be used to refer to this repository
#
echo "Adding remote connection to forked repository..."
git remote add $REMOTE $REMOTE_URL
catch_error $? "adding remote $REMOTE"

echo

# Fetch branch information
#
echo "Fetching remote branch information..."
git fetch $REMOTE
catch_error $? "fetching branches from remote $REMOTE"

echo

# Create the matching remote branch on the forked repository
#
# We need to explicitly create the branch via a push command
#
echo "Pushing local branch $BRANCH to remote $REMOTE..."
git push $REMOTE $BRANCH:refs/heads/$BRANCH
catch_error $? "pushing local branch $BRANCH to remote $REMOTE"

echo

# Configure the remote connection for the local branch
#
echo "Configuring remote connection for local branch $BRANCH..."

git config branch.$BRANCH.remote $REMOTE
catch_error $? "configuring remote $REMOTE for local branch $BRANCH"

git config branch.$BRANCH.merge refs/heads/$BRANCH
catch_error $? "configuring merge tracking for local branch $BRANCH"

exit 0
