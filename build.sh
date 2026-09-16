#!/usr/bin/env bash
# Znacznik wersji builda. Wartosci pochodza wylacznie z deployu (COMMIT_REF),
# nigdy z recznego wpisu w zrodle. Skrypt jest idempotentny: drugie uruchomienie
# nie znajduje juz placeholderow i niczego nie psuje.
set -euo pipefail

FILE="index.html"
PH_ID="__BUILD_ID__"
PH_DATE="__BUILD_DATE__"

[ -f "$FILE" ] || { echo "build.sh: brak $FILE" >&2; exit 1; }

if [ -z "${COMMIT_REF:-}" ]; then
  echo "build.sh: brak zmiennej COMMIT_REF - wersja musi pochodzic z deployu" >&2
  exit 1
fi

BUILD_ID="$(printf '%s' "$COMMIT_REF" | cut -c1-7)"
BUILD_DATE="$(date -u '+%Y-%m-%d %H:%M UTC')"

echo "build.sh: COMMIT_REF=$COMMIT_REF -> BUILD_ID=$BUILD_ID, BUILD_DATE=$BUILD_DATE"

# | jako separator: data zawiera dwukropki i spacje, ale nigdy pionowej kreski
sed -i "s|$PH_ID|$BUILD_ID|g; s|$PH_DATE|$BUILD_DATE|g" "$FILE"

if grep -q -e "$PH_ID" -e "$PH_DATE" "$FILE"; then
  echo "build.sh: po podmianie zostaly placeholdery:" >&2
  grep -n -e "$PH_ID" -e "$PH_DATE" "$FILE" >&2
  exit 1
fi

echo "build.sh: OK - zero pozostalych placeholderow"
