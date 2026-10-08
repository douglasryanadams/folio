# Hosting folio on S3 + CloudFront

One-time manual setup. Afterwards, `make deploy` publishes updates and
`make pull-media` restores images from S3.

Architecture: a **private** S3 bucket holds the built site (`_site/`) and the
media (under `media/`). CloudFront serves it over HTTPS on your custom domain,
reading the bucket through Origin Access Control (OAC). The bucket is never public.

Placeholders used below: `example.com` (your domain), `folio-site-example`
(your bucket name; must be globally unique), `us-east-1` (region).

## 1. Prerequisites

- An AWS account (use the root user only to create the admin/SSO user below).
- AWS CLI v2 (`aws --version`) and Docker (used by `make build`).
- A domain you control, and access to its DNS.

## 2. Access via IAM Identity Center (SSO)

1. AWS Console → **IAM Identity Center** → Enable (choose your home region).
2. **Users** → create yourself; set a password via the emailed invite.
3. **Permission sets** → create a custom one named `FolioDeploy` with this inline policy
   (replace the bucket name; distribution ARN can be tightened after step 5):

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
         "Resource": "arn:aws:s3:::folio-site-example"
       },
       {
         "Effect": "Allow",
         "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
         "Resource": "arn:aws:s3:::folio-site-example/*"
       },
       {
         "Effect": "Allow",
         "Action": ["cloudfront:CreateInvalidation", "cloudfront:GetDistribution"],
         "Resource": "*"
       }
     ]
   }
   ```

4. **AWS accounts** → select your account → Assign users → your user + `FolioDeploy`.
5. Configure the CLI:

   ```sh
   aws configure sso --profile folio   # use the SSO start URL shown in IAM Identity Center
   aws sso login --profile folio
   aws sts get-caller-identity --profile folio
   ```

   Sessions expire; re-run `aws sso login --profile folio` when the scripts tell you to.

> Creating the bucket, certificate and distribution below needs broader rights than
> the deploy permission set. Do those steps as an admin (e.g. a temporary
> `AdministratorAccess` assignment to yourself, removed afterwards).

## 3. S3 bucket

Console → S3 → **Create bucket**:

- Name `folio-site-example`, region `us-east-1`.
- Object Ownership: **ACLs disabled**.
- **Block all public access: ON** (all four boxes).
- Default encryption: SSE-S3.
- **Bucket Versioning: Enable.** This is your safety net because S3 may be the only copy of the images.

Then bucket → Management → **Lifecycle rules** → Create:

- Scope: whole bucket.
- Action: *Permanently delete noncurrent versions* after **90 days**.
- Action: *Delete expired object delete markers or incomplete multipart uploads* → incomplete multipart uploads after 7 days.

## 4. TLS certificate (ACM)

CloudFront only accepts certificates from **us-east-1**.

1. Console → Certificate Manager (region **N. Virginia**) → Request public certificate.
2. Names: `example.com` and `www.example.com`. Validation: DNS.
3. Create the validation CNAME record(s) at your DNS host (Route 53 has a one-click button).
4. Wait until status is **Issued**.

## 5. CloudFront distribution

Console → CloudFront → **Create distribution**:

- **Origin domain**: choose the S3 bucket (the `...s3.us-east-1.amazonaws.com` entry, *not* the website endpoint).
- **Origin access**: Origin access control settings (recommended) → Create new OAC (sign requests, defaults).
- **Viewer protocol policy**: Redirect HTTP to HTTPS.
- **Allowed methods**: GET, HEAD.
- **Cache policy**: `CachingOptimized`. Compress objects automatically: Yes.
- **Alternate domain names (CNAME)**: `example.com`, `www.example.com`.
- **Custom SSL certificate**: the ACM cert from step 4.
- **Supported HTTP versions**: HTTP/2 and HTTP/3. **Default root object**: `index.html`.
- Price class / WAF: your choice (WAF is not needed for a static portfolio).

Create it, then note the **Distribution ID** (like `E1234567890ABC`) and the
**Distribution domain name** (`dxxxxxxxx.cloudfront.net`).

Pages keep their `.html` names (`/about.html`), so no URL-rewrite function is needed.

## 6. Bucket policy

CloudFront shows a **Copy policy** banner after creating the distribution. If you
missed it, go to the distribution → Origins → select origin → Edit → *Copy policy*.
Paste it into S3 → bucket → Permissions → **Bucket policy**. It should look like:

```json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipal",
      "Effect": "Allow",
      "Principal": { "Service": "cloudfront.amazonaws.com" },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::folio-site-example/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::<ACCOUNT_ID>:distribution/<DISTRIBUTION_ID>"
        }
      }
    }
  ]
}
```

## 7. DNS

Point the domain at the distribution domain name from step 5:

- **Route 53**: create *A* and *AAAA* **Alias** records (to the CloudFront distribution) for `example.com` and `www`.
- **Other DNS host**: `www` → CNAME to `dxxxxxxxx.cloudfront.net`. For the apex (`example.com`) use
  ALIAS/ANAME/CNAME-flattening if your host supports it; otherwise redirect apex → `www` at the host.

DNS can take minutes to hours to propagate.

## 8. Configure the scripts

```sh
cp scripts/config.sh.example scripts/config.sh
```

Edit `scripts/config.sh` (gitignored): `AWS_PROFILE`, `AWS_REGION`, `BUCKET`,
`DISTRIBUTION_ID`, `SITE_URL`.

## 9. First deploy

```sh
aws sso login --profile folio
make deploy-dry-run     # builds, lists what would upload; changes nothing
make deploy             # uploads and invalidates CloudFront
```

What the scripts do:

| Content | Destination | Cache-Control | Deletes removed files? |
| --- | --- | --- | --- |
| `_site/media/` | `s3://BUCKET/media/` | 1 year, immutable | **No** |
| `_site/static/` (fonts) | `s3://BUCKET/static/` | 1 year, immutable | Yes |
| everything else (HTML, CSS) | bucket root | 5 minutes | Yes |

Because media is cached for a year, **never overwrite an image in place with a
different image**; use a new filename. (An invalidation on deploy also clears CloudFront's copy.)

Verify:

- [ ] `https://example.com/` loads; `http://` redirects to `https://`.
- [ ] `/about.html` and a photography page load; fonts and CSS apply.
- [ ] An image such as `/media/photography/golden_hour/1415.jpg` loads.
- [ ] `curl -I https://example.com/media/photography/golden_hour/1415.jpg` shows the long `cache-control` and `x-cache`.
- [ ] `https://folio-site-example.s3.us-east-1.amazonaws.com/index.html` returns **403** (bucket is private).

Options: `scripts/deploy.sh --skip-build` (reuse existing `_site/`), `--skip-media`
(HTML/CSS only; much faster), `--dry-run`.

## 10. Restoring media from S3

```sh
make pull-media                                          # all of s3://BUCKET/media -> ./media
scripts/pull-media.sh --prefix photography/golden_hour   # a subset
scripts/pull-media.sh --dry-run                          # preview
```

The pull never deletes local files, and `aws s3 sync` skips files whose size and
modified time already match. **Do a restore drill once** before relying on S3 as the
only copy: move `media/` aside, run `make pull-media`, then `diff -r media media.bak`.

If an image was overwritten or deleted by mistake, versioning has it (within the
90-day window):

```sh
aws s3api list-object-versions --profile folio --bucket folio-site-example \
  --prefix media/photography/golden_hour/1415.jpg
aws s3api get-object --profile folio --bucket folio-site-example \
  --key media/photography/golden_hour/1415.jpg --version-id <ID> restored.jpg
```

Note: original-resolution masters you want to keep forever should also have a second
backup (another bucket/region, external drive, or Lightroom catalog); a single S3 bucket is not a backup strategy.

## 11. Optional follow-ups

- AWS Budgets alert (e.g. $5/month) so surprises are caught early.
- A `404.html` page, then CloudFront → Error pages → map 403 and 404 to `/404.html` with a 404 status
  (S3 returns 403 for missing keys when the caller lacks `ListBucket`).
- CloudFront response headers policy (`SecurityHeadersPolicy`).
- Redirect `www` → apex (or reverse) with a CloudFront Function.
