#!/usr/bin/env bash

MAX_LENGTH=50

cd ~/.dotfiles || exit

nix fmt

# Check if the -a argument is passed
if [[ $1 == "-a" ]]; then
    # Append to the last commit without changing its message
    git add .
    git commit --amend --no-edit
else
    git status
    read -p "Enter your commit message: " COMMIT_MESSAGE

    COMMIT_MESSAGE_WITH_UNDERSCORES="${COMMIT_MESSAGE// /_}"
    SANITIZED_COMMIT_MESSAGE=$(echo "$COMMIT_MESSAGE_WITH_UNDERSCORES" | tr -dc '[:alnum:]._-')

    # Extract the first MAX_LENGTH characters from the sanitized commit message, truncate if necessary, and set it as an environment variable
    if [[ ${#SANITIZED_COMMIT_MESSAGE} -gt MAX_LENGTH ]]; then
        NIXOS_LABEL_VERSION=${SANITIZED_COMMIT_MESSAGE:0:MAX_LENGTH}...
    else
        NIXOS_LABEL_VERSION=$SANITIZED_COMMIT_MESSAGE
    fi

    LABEL_NIX_CONTENT="\"$NIXOS_LABEL_VERSION\""
    printf "$LABEL_NIX_CONTENT" > ./modules/label.nix


    git add .
    git commit -m "$COMMIT_MESSAGE"
fi

FLAKE=~/.dotfiles/ nh os switch --ask
