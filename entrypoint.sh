#!/bin/bash
set -e

eval "$(mise activate bash)"

# Git config
[[ -n "$GIT_USER_NAME" ]] && git config --global user.name "$GIT_USER_NAME"
[[ -n "$GIT_USER_EMAIL" ]] && git config --global user.email "$GIT_USER_EMAIL"

# GitHub CLI auth
[[ -n "$GITHUB_TOKEN" ]] && echo "$GITHUB_TOKEN" | gh auth login --with-token

exec opencode serve --hostname 0.0.0.0 --port "${PORT:-4096}"
