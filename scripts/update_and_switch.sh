#!/usr/bin/env bash

default_host="crusader"
host=$default_host
MAX_LENGTH=50

function yes_or_no {
  while true; do
      read -p "$* [y/n]: " yn
      case $yn in
          [Yy]*) return 0  ;;  
          [Nn]*) echo "Aborted" ; return  1 ;;
      esac
  done
}

# Parse command line arguments
while getopts ":h:" opt; do
  case $opt in
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

lazygit || exit 1
COMMIT_MESSAGE=$(git log -1 --pretty=%B)
COMMIT_MESSAGE_WITH_UNDERSCORES="${COMMIT_MESSAGE// /_}"
SANITIZED_COMMIT_MESSAGE=$(echo "$COMMIT_MESSAGE_WITH_UNDERSCORES" | tr -dc '[:alnum:]._-')
# Extract the first MAX_LENGTH characters from the sanitized commit message, truncate if necessary, and set it as an environment variable
if [[ ${#SANITIZED_COMMIT_MESSAGE} -gt MAX_LENGTH ]]; then
    NIXOS_LABEL_VERSION=${SANITIZED_COMMIT_MESSAGE:0:MAX_LENGTH}...
else
    NIXOS_LABEL_VERSION=$SANITIZED_COMMIT_MESSAGE
fi

yes_or_no "${host}: ${NIXOS_LABEL_VERSION}?"|| exit 1


LABEL_NIX_CONTENT="\"$NIXOS_LABEL_VERSION\""
printf "%s" "$LABEL_NIX_CONTENT" > ./modules/common/label.nix


nix fmt
git add ./modules/common/label.nix
git commit --amend --no-edit 


if [ "$host" == "$default_host" ]; then
    NH_FLAKE=~/.dotfiles/ nh os switch --ask
else
    # Don't know how to use nh tool with remote machines, so fallback to default for now
    nixos-rebuild switch --flake ".#$host" --target-host "$host" --use-remote-sudo --build-host "$host"
fi
