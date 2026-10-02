# Folio

A portfolio site for digital illustrations and photography.

Built iteratively, one narrow step at a time.

## Ground rules

1. Vanilla JavaScript, vanilla CSS, vanilla HTML for everything possible — no frameworks.
2. Linters for JavaScript, CSS, and HTML run in Docker containers.
3. Bun is the runtime for JavaScript scripts and tests.
4. Keep the code simple and straightforward.
5. Prefer CSS over JavaScript for visual formatting and adjustment.
6. Use modern HTML layout features (Flex, Grid) appropriately.

See [PLAN.md](./PLAN.md) for deferred/future work.

## Common commands

```sh
make start   # start the dev environment (webserver + S3-compatible store)
make stop    # stop it
make format  # auto-fix JS/CSS style issues
make lint    # format, then run all linters (JS, CSS, HTML) in Docker
make test    # run the test suite with Bun, in Docker
make check   # lint + test
```

## Getting started

Open `index.html` directly in a browser to view the current page skeleton, or
run the dev environment (see below) to view it served over HTTP with image
proxying to the local S3-compatible store.

## Development environment

`docker-compose.yml` runs a local stack mirroring how the site will be served
in production (static assets + images via S3 behind CloudFront):

- **webserver** — Nginx, serves the static site and reverse-proxies
  `/media/*` to the S3-compatible store, so the site references the same
  `/media/...` paths in dev and production.
- **s3** — [SeaweedFS](https://github.com/seaweedfs/seaweedfs) running as an
  all-in-one server with its S3 API gateway enabled, standing in for S3 in
  dev. No auth is configured, so it accepts requests anonymously (fine for
  local dev; production uses real S3 + CloudFront, see `PLAN.md`).
- **s3-init** — a one-shot container that creates the `folio` bucket and
  uploads a sample image via plain S3 REST calls, then exits.

```sh
docker compose up
```

- Site: http://localhost:8080
- Sample image via the proxy: http://localhost:8080/media/sample.svg
- SeaweedFS S3 API directly (for debugging): http://localhost:8333

Stop the stack with `docker compose down` (add `-v` to also clear the stored
objects).

## Linting and tests

Linters and tests run inside Docker containers — no local Node/Bun install required.

```sh
# build the images
docker compose -f docker-compose.lint.yml build

# run an individual linter, or the test suite
docker compose -f docker-compose.lint.yml run --rm lint-js
docker compose -f docker-compose.lint.yml run --rm lint-css
docker compose -f docker-compose.lint.yml run --rm lint-html
docker compose -f docker-compose.lint.yml run --rm test
```
