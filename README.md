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

## Getting started

Open `index.html` directly in a browser to view the current page skeleton.

## Linting

Linters run inside Docker containers — no local Node/Bun install required to lint.

```sh
# build the lint image
docker compose -f docker-compose.lint.yml build

# run an individual linter
docker compose -f docker-compose.lint.yml run --rm lint-js
docker compose -f docker-compose.lint.yml run --rm lint-css
docker compose -f docker-compose.lint.yml run --rm lint-html
```
