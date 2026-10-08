#!/usr/bin/env bash
# Download media from S3 into ./media. Never deletes local files.
# Usage: scripts/pull-media.sh [--dry-run] [--prefix photography/golden_hour]
source "$(dirname "$0")/common.sh"

DRY_RUN=""
PREFIX=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN="--dryrun"; shift ;;
    --prefix)
      [[ $# -ge 2 ]] || { echo "--prefix needs a value" >&2; exit 2; }
      PREFIX="${2#/}"; PREFIX="${PREFIX%/}"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

SRC="s3://$BUCKET/media${PREFIX:+/$PREFIX}"
DEST="media${PREFIX:+/$PREFIX}"
mkdir -p "$DEST"

echo "==> Pulling $SRC -> $DEST"
aws s3 sync "$SRC" "$DEST" $DRY_RUN
