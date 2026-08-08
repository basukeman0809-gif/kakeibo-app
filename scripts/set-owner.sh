#!/usr/bin/env bash
# 家計簿エントリー1件のownerフィールドを設定/上書きする。
# 複数人対応の初期移行（既存データへのowner付与）や、記録の持ち主を修正したいときに使う。
# Usage: set-owner.sh <document-id> <owner>
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: set-owner.sh <document-id> <owner>" >&2
  exit 1
fi

DOC_ID="$1"
OWNER="$2"

PROJECT="kakeibo-app-ac30a"
URL="https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/entries/${DOC_ID}?updateMask.fieldPaths=owner"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}
OWNER_ESC="$(json_escape "$OWNER")"

TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT

cat > "$TMPFILE" <<JSON
{
  "fields": {
    "owner": {"stringValue": "${OWNER_ESC}"}
  }
}
JSON

RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X PATCH "$URL" -H "Content-Type: application/json" --data "@$TMPFILE")
STATUS=$(printf '%s' "$RESPONSE" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)

if [ "$STATUS" != "200" ]; then
  echo "owner更新に失敗しました (status: $STATUS)" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "OK: ${DOC_ID} -> owner=${OWNER}"
