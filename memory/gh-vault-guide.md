This is a guide for people who'd like to build memory vault/sync using GitHub, based on my memory/ system.

First check if `[your user name]/claude-memory-sync` already exist, if exist, just clone it.

Otherwise create `~/.claude-memory-sync`. And create `update.sh` in that directory with content:
```bash
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SOURCE_FILE="${CLAUDE_MEMORY_FILE:-$HOME/.claude/memory/promoted.md}"

get_machine_id() {
  if [[ -r /etc/machine-id ]]; then
    cat /etc/machine-id
    return
  fi

  if command -v ioreg >/dev/null 2>&1; then
    ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/ {print $4}'
    return
  fi

  return 1
}

MACHINE_ID=$(get_machine_id)
NAME="$(hostname)-${MACHINE_ID}"
TARGET_DIR="${ROOT_DIR}/machines"
TARGET_FILE="${TARGET_DIR}/${NAME}.md"

echo "Host name: ${NAME}"

if [[ ! -f "${SOURCE_FILE}" ]]; then
  echo "Missing Claude memory file: ${SOURCE_FILE}" >&2
  exit 1
fi

cd "${ROOT_DIR}"

if [[ -d .git ]]; then
  echo "Pulling latest changes..."
  git pull --rebase
fi

echo "Copying..."
mkdir -p "${TARGET_DIR}"
cp "${SOURCE_FILE}" "${TARGET_FILE}"

if [[ -d .git ]]; then
  git add "${TARGET_FILE}"

  if git diff --cached --quiet -- "${TARGET_FILE}"; then
    echo "No changes to commit."
    exit 0
  fi

  git commit -m "update ${NAME} memory"
  git push
fi
```

Make your first commit, create a GitHub private repo `[your user name]/claude-memory-sync`, push to it.

On memory (promoted.md) update, run `~/.claude-memory-sync/update.sh`, it will commit and push for you. Each machine has individual memory promoted.md, distinguished.

promoted.md is the source of truth after distill. You can recover all memory from it.

On recovery, let the agent build the other files, based on my archibate/dotfiles-claude repo memory/ system.

Memory can contain user sensive information, so keep it a private repo.
