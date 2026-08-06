#!/usr/bin/env bash
# 家計簿エントリーをFirestoreから1件削除する。
# Usage: delete-entry.sh <document-id>
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: delete-entry.sh <document-id>" >&2
  exit 1
fi

DOC_ID="$1"
PROJECT="kakeibo-app-ac30a"
URL="https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/entries/${DOC_ID}"

RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X DELETE "$URL")
STATUS=$(printf '%s' "$RESPONSE" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)

if [ "$STATUS" != "200" ]; then
  echo "Firestoreからの削除に失敗しました (status: $STATUS)" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "OK: deleted ${DOC_ID}"
