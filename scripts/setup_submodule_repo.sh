#!/usr/bin/env bash

echo "$1"

# For some reason, local config does not work...
git config --global url."$1".insteadOf "my-git:"
