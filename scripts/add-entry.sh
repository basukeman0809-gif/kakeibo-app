#!/usr/bin/env bash
# 家計簿エントリーをFirestoreに1件追加する。
# Usage: add-entry.sh <date:YYYY-MM-DD> <type:expense|income> <category> <amount> <memo> [owner]
# ownerを省略した場合は ryosuke（このチャットの通常利用者）になる。
set -euo pipefail

if [ "$#" -ne 5 ] && [ "$#" -ne 6 ]; then
  echo "Usage: add-entry.sh <date> <type> <category> <amount> <memo> [owner]" >&2
  exit 1
fi

DATE="$1"
TYPE="$2"
CATEGORY="$3"
AMOUNT="$4"
MEMO="$5"
OWNER="${6:-ryosuke}"
CREATED_AT="$(date +%s%3N)"

PROJECT="kakeibo-app-ac30a"
URL="https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/entries"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

DATE_ESC="$(json_escape "$DATE")"
TYPE_ESC="$(json_escape "$TYPE")"
CATEGORY_ESC="$(json_escape "$CATEGORY")"
MEMO_ESC="$(json_escape "$MEMO")"
OWNER_ESC="$(json_escape "$OWNER")"

# Windows環境ではcurlの引数(argv)経由だとコンソールのコードページ変換で
# 日本語などのマルチバイト文字が化けることがあるため、JSON本文は一時ファイル経由で渡す。
TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT

cat > "$TMPFILE" <<JSON
{
  "fields": {
    "date": {"stringValue": "${DATE_ESC}"},
    "type": {"stringValue": "${TYPE_ESC}"},
    "category": {"stringValue": "${CATEGORY_ESC}"},
    "amount": {"integerValue": "${AMOUNT}"},
    "memo": {"stringValue": "${MEMO_ESC}"},
    "createdAt": {"integerValue": "${CREATED_AT}"},
    "owner": {"stringValue": "${OWNER_ESC}"}
  }
}
JSON

RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$URL" -H "Content-Type: application/json" --data "@$TMPFILE")
STATUS=$(printf '%s' "$RESPONSE" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)

if [ "$STATUS" != "200" ]; then
  echo "Firestoreへの書き込みに失敗しました (status: $STATUS)" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "OK: [${OWNER}] ${DATE} ${TYPE} ${CATEGORY} ${AMOUNT}円 ${MEMO}"
