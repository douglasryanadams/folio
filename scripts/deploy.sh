#!/usr/bin/env bash
# Build the site and push it to S3, then invalidate CloudFront.
# Usage: scripts/deploy.sh [--dry-run] [--skip-build] [--skip-media]
source "$(dirname "$0")/common.sh"

DRY_RUN=""
SKIP_BUILD=0
SKIP_MEDIA=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN="--dryrun" ;;
    --skip-build) SKIP_BUILD=1 ;;
    --skip-media) SKIP_MEDIA=1 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

LONG_CACHE="public, max-age=31536000, immutable"
SHORT_CACHE="public, max-age=300"

if [[ $SKIP_BUILD -eq 0 ]]; then
  make build
fi
[[ -f _site/index.html ]] || { echo "_site/index.html missing; build failed?" >&2; exit 1; }

if [[ $SKIP_MEDIA -eq 0 && -d _site/media ]]; then
  echo "==> Media (never deletes from S3)"
  aws s3 sync _site/media "s3://$BUCKET/media" \
    --exclude ".DS_Store" --cache-control "$LONG_CACHE" $DRY_RUN
fi

if [[ -d _site/static ]]; then
  echo "==> Static assets (fonts)"
  aws s3 sync _site/static "s3://$BUCKET/static" \
    --delete --cache-control "$LONG_CACHE" $DRY_RUN
fi

echo "==> Site (HTML, CSS)"
aws s3 sync _site "s3://$BUCKET" \
  --exclude "media/*" --exclude "static/*" --exclude ".DS_Store" \
  --delete --cache-control "$SHORT_CACHE" $DRY_RUN

if [[ -n "$DRY_RUN" ]]; then
  echo "Dry run complete; no changes made, no invalidation."
  exit 0
fi

echo "==> Invalidating CloudFront"
aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*" \
  --query "Invalidation.Id" --output text

echo "Deployed: ${SITE_URL:-https://$BUCKET}"
