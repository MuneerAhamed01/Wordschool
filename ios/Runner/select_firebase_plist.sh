#!/bin/sh
# Copies the flavor-specific GoogleService-Info.plist into Runner/ before the
# Resources build phase bundles it. CONFIGURATION is e.g. Debug-dev, Release-prod.
set -e

DEST="${SRCROOT}/Runner/GoogleService-Info.plist"

if echo "${CONFIGURATION}" | grep -q '\-dev'; then
  SRC="${SRCROOT}/flavors/dev/GoogleService-Info.plist"
else
  SRC="${SRCROOT}/flavors/prod/GoogleService-Info.plist"
fi

if [ ! -f "${SRC}" ]; then
  echo "error: Firebase plist not found at ${SRC}" >&2
  exit 1
fi

cp "${SRC}" "${DEST}"
echo "Copied $(basename "${SRC}") for ${CONFIGURATION}"
