#!/bin/sh
set -eu

S3_URL="http://s3:8333"
BUCKET="folio"

until curl -s -o /dev/null "$S3_URL/"; do
  sleep 1
done

curl -s -X PUT "$S3_URL/$BUCKET"
curl -s -X PUT --data-binary @/seed/sample.svg \
  -H "Content-Type: image/svg+xml" \
  "$S3_URL/$BUCKET/sample.svg"

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
  for file in /media-local/*; do
    [ -f "$file" ] || continue
    name=$(basename "$file")
    curl -s -X PUT --data-binary @"$file" \
      -H "Content-Type: $(content_type_for "$name")" \
      "$S3_URL/$BUCKET/$name"
  done
fi
