#!/bin/sh
set -eu

S3_URL="http://s3:8333"
BUCKET="folio"

until curl -s -o /dev/null "$S3_URL/"; do
  sleep 1
done

curl -s -X PUT "$S3_URL/$BUCKET"

content_type_for() {
  case "$1" in
    *.jpg | *.jpeg) echo "image/jpeg" ;;
    *.png) echo "image/png" ;;
    *.gif) echo "image/gif" ;;
    *.webp) echo "image/webp" ;;
    *.svg) echo "image/svg+xml" ;;
    *) echo "application/octet-stream" ;;
  esac
}

if [ -d /media-local ]; then
  # Subdirectories become key prefixes (S3 has no real folders).
  echo "Uploading files from /media-local"
  find /media-local -type f -not -name ".*" | while IFS= read -r file; do
    key="${file#/media-local/}"
    echo "Uploading $key to $S3_URL/$BUCKET/$key as $(content_type_for "$key")"
    curl -s -f -X PUT --data-binary @"$file" \
      -H "Content-Type: $(content_type_for "$key")" \
      "$S3_URL/$BUCKET/$key"
  done
fi
