#!/usr/bin/env bash

MAX_LENGTH=50

cd ~/.dotfiles || exit

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

LABEL_NIX_CONTENT="{...}:\n{\n  system.nixos.label = \"$NIXOS_LABEL_VERSION\";\n}"
printf "$LABEL_NIX_CONTENT" > label.nix


git add .
git commit -m "$COMMIT_MESSAGE"

FLAKE=~/.dotfiles/ nh os switch --ask
