# Shared setup for deploy.sh and pull-media.sh. Source this; do not execute it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -f scripts/config.sh ]]; then
  echo "Missing scripts/config.sh. Copy scripts/config.sh.example and fill it in." >&2
  exit 1
fi
# shellcheck source=/dev/null
source scripts/config.sh

export AWS_PROFILE AWS_REGION AWS_PAGER=""

if ! command -v aws >/dev/null; then
  echo "AWS CLI not found. Install AWS CLI v2." >&2
  exit 1
fi

if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "AWS session for profile '$AWS_PROFILE' is missing or expired." >&2
  echo "Run: aws sso login --profile $AWS_PROFILE" >&2
  exit 1
fi
