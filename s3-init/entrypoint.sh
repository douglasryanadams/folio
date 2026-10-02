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
