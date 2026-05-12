#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="/workspace"

prompt() {
    # Read a single line from the controlling terminal so this works when piped
    local __varname="$1"
    local __message="$2"
    local __reply
    if [[ -r /dev/tty ]]; then
        printf "%s" "$__message" > /dev/tty
        IFS= read -r __reply < /dev/tty
    else
        printf "%s" "$__message"
        IFS= read -r __reply
    fi
    printf -v "$__varname" '%s' "$__reply"
}

detect_platform_from_tokens() {
    local detected=()
    [[ -n "${ADO_TOKEN:-}" ]] && detected+=("ado")
    [[ -n "${BITBUCKET_TOKEN:-}" ]] && detected+=("bitbucket")
    [[ -n "${GITLAB_TOKEN:-}" ]] && detected+=("gitlab")

    if [[ ${#detected[@]} -eq 1 ]]; then
        PLATFORM="${detected[0]}"
    elif [[ ${#detected[@]} -gt 1 ]]; then
        echo "Multiple platform tokens detected: ${detected[*]}"
        local choice
        while :; do
            prompt choice "Which platform do you want to use? [${detected[*]}]: "
            choice="$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]')"
            for p in "${detected[@]}"; do
                if [[ "$p" == "$choice" ]]; then
                    PLATFORM="$choice"
                    return
                fi
            done
            echo "Invalid choice: '$choice'"
        done
    fi
}

ask_platform() {
    local choice
    while :; do
        prompt choice "Which platform are you using? [ado/bitbucket/gitlab]: "
        choice="$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]')"
        case "$choice" in
            ado|azure|azuredevops|azure-devops) PLATFORM="ado"; return ;;
            bitbucket|bb) PLATFORM="bitbucket"; return ;;
            gitlab|gl) PLATFORM="gitlab"; return ;;
            *) echo "Invalid choice: '$choice'" ;;
        esac
    done
}

PLATFORM=""
detect_platform_from_tokens
if [[ -z "$PLATFORM" ]]; then
    ask_platform
fi

case "$PLATFORM" in
    ado)
        : "${ADO_TOKEN:?Environment variable ADO_TOKEN is not set}"
        TOKEN="$ADO_TOKEN"
        REPOS_VAR="ADO_REPOS"
        ;;
    bitbucket)
        : "${BITBUCKET_TOKEN:?Environment variable BITBUCKET_TOKEN is not set}"
        TOKEN="$BITBUCKET_TOKEN"
        REPOS_VAR="BITBUCKET_REPOS"
        ;;
    gitlab)
        : "${GITLAB_TOKEN:?Environment variable GITLAB_TOKEN is not set}"
        TOKEN="$GITLAB_TOKEN"
        REPOS_VAR="GITLAB_REPOS"
        ;;
esac

if [[ -n "${CLONE_REPOS:-}" ]]; then
    REPOS_RAW="$CLONE_REPOS"
elif [[ -n "${!REPOS_VAR:-}" ]]; then
    REPOS_RAW="${!REPOS_VAR}"
else
    echo "Environment variable CLONE_REPOS or $REPOS_VAR is not set" >&2
    exit 1
fi

mkdir -p "$TARGET_DIR"

IFS=',' read -ra REPOS <<< "$REPOS_RAW"

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

    case "$PLATFORM" in
        ado)
            clone_url="https://${TOKEN}@dev.azure.com/${workspace}/${repo}/_git/${repo}"
            ;;
        bitbucket)
            clone_url="https://x-token-auth:${TOKEN}@bitbucket.org/${workspace}/${repo}.git"
            ;;
        gitlab)
            clone_url="https://oauth2:${TOKEN}@gitlab.com/${workspace}/${repo}.git"
            ;;
    esac

    echo "Cloning $workspace/$repo into $dest"
    git clone "$clone_url" "$dest"
done
