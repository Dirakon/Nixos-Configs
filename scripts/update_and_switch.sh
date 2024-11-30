#!/usr/bin/env bash

ammend_commit=false
host=""
MAX_LENGTH=50

# Parse command line arguments
while getopts ":ah:" opt; do
  case $opt in
    a)
      ammend_commit=true
      ;;
    h)
      host="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Shift past parsed arguments
shift $((OPTIND - 1))

cd ~/.dotfiles || exit
~/.dotfiles/scripts/actualize_submodule_flakes.sh
nix fmt

if $ammend_commit; then
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
    printf "%s" "$LABEL_NIX_CONTENT" > ./modules/common/label.nix


    nix fmt
    git add .
    git commit -m "$COMMIT_MESSAGE"
fi


if [ "$host" == "" ]; then
    # Default host (this)
    FLAKE=~/.dotfiles/ nh os switch --ask
else
    # Don't know how to use nh tool with remote machines, so fallback to default for now
    nixos-rebuild switch --flake ".#$host" --target-host "$host" --use-remote-sudo
fi
