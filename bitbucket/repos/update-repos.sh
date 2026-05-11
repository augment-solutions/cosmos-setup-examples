#!/usr/bin/env bash
set -euo pipefail

: "${BITBUCKET_REPOS:?Environment variable BITBUCKET_REPOS is not set}"

TARGET_DIR="/workspace"

IFS=',' read -ra REPOS <<< "$BITBUCKET_REPOS"

for entry in "${REPOS[@]}"; do
    # Trim surrounding whitespace
    entry="${entry#"${entry%%[![:space:]]*}"}"
    entry="${entry%"${entry##*[![:space:]]}"}"

    if [[ -z "$entry" ]]; then
        continue
    fi

    if [[ "$entry" != */* ]]; then
        echo "Skipping invalid entry (expected <workspace>/<repo>): '$entry'" >&2
        continue
    fi

    workspace="${entry%%/*}"
    repo="${entry#*/}"

    if [[ -z "$workspace" || -z "$repo" ]]; then
        echo "Skipping invalid entry (empty workspace or repo): '$entry'" >&2
        continue
    fi

    dest="$TARGET_DIR/$repo"

    if [[ ! -d "$dest/.git" ]]; then
        echo "Skipping '$entry': '$dest' is not a git repository" >&2
        continue
    fi

    echo "Updating $workspace/$repo in $dest"
    git -C "$dest" pull
done