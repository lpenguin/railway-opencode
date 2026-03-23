#!/bin/bash
set -e

# If running as root, seed the volume (volume is root-owned) then drop to opencode
if [[ "$(id -u)" -eq 0 ]]; then
    if [[ ! -d "$HOME/.mise" ]]; then
        cp -a /opt/seed/. "$HOME/"
        chown -R opencode:opencode "$HOME"
    fi
    exec su -s /bin/bash -c "exec $0 $*" opencode
fi

eval "$(mise activate bash)"

[[ -n "$GIT_USER_NAME" ]] && git config --global user.name "$GIT_USER_NAME"
[[ -n "$GIT_USER_EMAIL" ]] && git config --global user.email "$GIT_USER_EMAIL"
[[ -n "$GITHUB_TOKEN" ]] && echo "$GITHUB_TOKEN" | gh auth login --with-token

exec opencode serve --hostname 0.0.0.0 --port "${PORT:-4096}"
