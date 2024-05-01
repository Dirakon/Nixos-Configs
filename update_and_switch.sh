#!/usr/bin/env bash

# Configurable parameter: Maximum length of the commit message to be used for NIXOS_LABEL_VERSION
MAX_LENGTH=50

# Change directory to '~/.dotfiles'
cd ~/.dotfiles || exit

git status

# Ask the user to input a commit message
read -p "Enter your commit message: " COMMIT_MESSAGE

# Add all changes and commit with the given message
git add .
git commit -m "$COMMIT_MESSAGE"


COMMIT_MESSAGE_WITH_UNDERSCORES="${COMMIT_MESSAGE// /_}"

# Sanitize the commit message to match the regex [a-zA-Z0-9:_\.-]* and remove characters that don't match
SANITIZED_COMMIT_MESSAGE=$(echo "$COMMIT_MESSAGE_WITH_UNDERSCORES" | tr -dc '[:alnum:]._-')

# Extract the first MAX_LENGTH characters from the sanitized commit message, truncate if necessary, and set it as an environment variable
if [[ ${#SANITIZED_COMMIT_MESSAGE} -gt MAX_LENGTH ]]; then
    NIXOS_LABEL_VERSION=${SANITIZED_COMMIT_MESSAGE:0:MAX_LENGTH}...
else
    NIXOS_LABEL_VERSION=$SANITIZED_COMMIT_MESSAGE
fi
export NIXOS_LABEL_VERSION

# Run the command 'FLAKE=~/.dotfiles/ nh os switch'
FLAKE=~/.dotfiles/ nh os switch
#echo $COMMIT_MESSAGE
#echo $NIXOS_LABEL_VERSION
