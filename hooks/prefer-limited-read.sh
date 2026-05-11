#!/usr/bin/bash
# PreToolUse hook on Read: deny no-limit Read on large files (>=300 lines OR >=10 KB).
# Suggests offset+limit OR Grep based on whether Claude knows the
# range or is searching for an identifier. Setting any `limit:`
# bypasses (so `limit: 99999` is the escape hatch for genuine full reads).
#
# Thresholds calibrated from ~3-day Read history:
#   10 KB ≈ p80 of unlimited Reads; this band captures 56% of unlimited Read bytes.
#   300 lines ≈ 10 KB at the empirical ~33 chars/line for Python/TS code.
#   OR-logic catches outliers in both dimensions (logs with long lines, JSON
#   with many short lines).
set -euo pipefail

source "$(dirname "$0")/lib/emit.sh"
source "$(dirname "$0")/lib/read_input.sh"

read_file_path

# If limit is already set, allow.
limit=$(jq -r '.tool_input.limit // empty' <<< "$input")
[ -n "$limit" ] && exit 0

# Need a regular, readable file on disk.
[ -f "$file_path" ] && [ -r "$file_path" ] || exit 0

# Skip binaries — line count is meaningless and Read handles them specially.
case "$(file -b --mime "$file_path" 2>&1)" in
    *charset=binary*) exit 0 ;;
esac

lines=$(wc -l < "$file_path") || exit 0
bytes=$(wc -c < "$file_path") || exit 0
case "$lines$bytes" in *[!0-9]*|"") exit 0 ;; esac
[ "$lines" -ge 300 ] || [ "$bytes" -ge 10000 ] || exit 0

kb=$(( (bytes + 512) / 1024 ))

emit_pre_tool_deny "File '$file_path' is $lines lines and ${kb} KB — a full Read pins it in context and gets re-read on every subsequent turn. Pick one:
  1. If you know the range, use offset+limit:
       Read(file_path=\"$file_path\", offset=<start_line>, limit=100)
  2. If you're searching for a specific identifier, use Grep:
       Grep(pattern=\"<identifier>\", path=\"$file_path\", output_mode=\"content\", -n=true)
  3. If you genuinely need the whole file, bypass with an explicit large limit (e.g., limit=2000)."
