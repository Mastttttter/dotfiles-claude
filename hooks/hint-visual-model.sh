#!/usr/bin/env bash
FILE=$(jq -r '.tool_input.file_path // empty')
[[ -z "$FILE" ]] && exit 0

EXT="${FILE##*.}"
EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

case "$EXT_LOWER" in
  png|jpg|jpeg|gif|bmp|webp|svg|ico|tiff|tif|heic|heif|avif)
    echo '{"systemMessage": "Visual content detected. Consider /model sonnet for better image understanding."}'
    ;;
esac
