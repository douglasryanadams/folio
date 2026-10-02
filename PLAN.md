# Future work

- In production, the S3 bucket should be private with CloudFront using
  Origin Access Control (OAC) to reach it — unlike the local dev SeaweedFS
  bucket, which accepts anonymous requests for simplicity. This is purely an
  infra difference; the `/media/...` URL shape stays the same.
- MinIO was evaluated for the local dev object store and rejected: its
  container registry (`minio/minio` on Docker Hub, `quay.io/minio/minio`)
  now requires authentication to pull (a 2025 licensing/distribution
  change). Don't reconsider it without checking whether that's changed.
- Eventually add Shopify integration and a mailing list service. Likely
  client-side embeds / small API calls layered on top of the finished site —
  not expected to require changes to the dev environment or current
  architecture, so not designing for it yet.
