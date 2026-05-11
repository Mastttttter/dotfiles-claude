#!/usr/bin/bash
# PreToolUse hook: when Claude is about to call WebFetch, nudge it to load
# the `read-url` skill instead — it returns clean complete markdown and
# bypasses WebFetch's truncation/summarization/refusal cases. Fires at most
# once per session_id to avoid re-prompting on iterative fetches.
#
# Non-blocking by design: WebFetch is fine for trivial fetches when the
# defuddle / jina-reader fallback chain is unnecessary.
#
# Sibling hook `hint-skill-jina-ai.sh` covers WebSearch → /jina-ai.
set -euo pipefail

source "$(dirname "$0")/lib/emit.sh"

input=$(cat)

SID=$(jq -r '.session_id // "unknown"' <<< "$input")
CACHE_DIR=/tmp/claude-skill-hint-read-url
CACHE="$CACHE_DIR/$SID"
mkdir -p "$CACHE_DIR"
[ -f "$CACHE" ] && exit 0
touch "$CACHE"

emit_pre_tool_warn 'About to call WebFetch. Consider the /read-url skill — it returns clean, complete markdown for the whole page (articles, docs, READMEs, papers) and avoids WebFetch'\''s truncation, summarization, or refusal behaviors. Built-in WebFetch is fine for trivial fetches where a short summary is enough.'
