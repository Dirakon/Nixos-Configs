#!/usr/bin/env bash

echo $1

git config url."$1".insteadOf "git-server:"
