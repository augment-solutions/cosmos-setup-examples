#!/usr/bin/env bash
set -euo pipefail

: "${BITBUCKET_REPOS:?Environment variable BITBUCKET_REPOS is not set}"
: "${BITBUCKET_TOKEN:?Environment variable BITBUCKET_TOKEN is not set}"

TARGET_DIR="/workspace"
mkdir -p "$TARGET_DIR"

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

    dest="$TARGET_DIR/$workspace/$repo"

    if [[ -d "$dest" ]]; then
        echo "Skipping '$entry': destination '$dest' already exists"
        continue
    fi

    mkdir -p "$TARGET_DIR/$workspace"

    echo "Cloning $workspace/$repo into $dest"
    git clone "https://x-token-auth:${BITBUCKET_TOKEN}@bitbucket.org/${workspace}/${repo}.git" "$dest"
done