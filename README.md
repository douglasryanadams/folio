# Folio

A portfolio site for digital illustrations and photography.

Built iteratively, one narrow step at a time.

## AI Disclaimer

I'm a software engineer, a digital artist, and a photographer. This puts me at the intersection of the AI debate that I'm still forming my own thoughts around. Here's where I'm at right now: AI is a tool that amplifies my creativity by limiting the energy I spend on the tedium that often accompanies software engineering.

Is the work creative? Should the work be creative? Am I using the work to represent something about my view of the world or message I want to communicate? If so, I'm not using AI for that work. This (obviously) includes all of my creative work as a digital artist and photographer. This also includes the majority of the software in this repository and the layout of this website.

So what do I use AI for?

1. I used it to set this project up. At the beginning of a software project there is a lot of "boilerplate" that I've already done, by hand, dozens if not hundreds of times myself over the last 15 years. Claude Code can do it for me, exactly the way I want it done in about 1/20th of the time it would take me. I get no joy from setting projects up, it's not creative, it's reading manuals to remember details I forgot and spending hours hunting for syntax errors. Claude Code liberates me from this.
2. I use it occasionally to help me troubleshoot issues or learn about technologies. In this sense, it's a more effective search engine, finding me contextually relevant information that I can use to improve my own skills and knowledge. This helps me save my energy to focus on more creative aspects of building this website and avoid digging through StackOverflow and poorly written documentation for hours.
3. In my photography, I sometimes use the AI Denoise feature of Lightroom to bring back details of high noise images that could not be captured with less noise.
4. In the future, if I choose to share event or portrait photography, I may use AI powered image manipulation features such as heal or generative fill delete tools to work around circumstances outside my control when capturing the image.

I am sure this is troubling for some readers, as a visual artist there are a lot of real threats to the industry from AI tools. There are also real ethical concerns with the provenance and maintenance of these tools in addition to the considerable environmental concerns. Those are also part of my personal considerations when using these tools.

Unfortunately, the reality for nearly anyone hosting a website in 2026 (and likely the future) is that any popular tool (Wix, SquareSpace, WordPress, etc.) is certainly using more agentic tools than I am in this project.

## Ground rules

1. Vanilla JavaScript, vanilla CSS, vanilla HTML for everything possible — no frameworks.
2. Linters for JavaScript, CSS, and HTML run in Docker containers.
3. Bun is the runtime for JavaScript scripts and tests.
4. Keep the code simple and straightforward.
5. Prefer CSS over JavaScript for visual formatting and adjustment.
6. Use modern HTML layout features (Flex, Grid) appropriately.

## Common commands

```sh
make start   # start the dev environment (webserver + S3-compatible store)
make stop    # stop it
make dev     # same stack as start, but nginx caching is off (just refresh to see edits)
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
- **s3-init** — a one-shot container that creates the `folio` bucket,
  uploads the sample image, and uploads everything in `media-local/` (see
  below), via plain S3 REST calls, then exits.

```sh
docker compose up
```

- Site: http://localhost:8080
- Sample image via the proxy: http://localhost:8080/media/sample.svg
- SeaweedFS S3 API directly (for debugging): http://localhost:8333

Stop the stack with `docker compose down` (add `-v` to also clear the stored
objects).

### Adding real images without committing them

Drop image files into `media-local/` (gitignored, created on first use).
Every file in it gets uploaded to the S3 store on `docker compose up`, and
becomes reachable at `/media/<path>`, same as `seed/sample.svg`. Subfolders
are supported: `media-local/photos/2024/a.jpg` is served at
`/media/photos/2024/a.jpg` (S3 has no real folders; the subpath is just part
of the object key, and SeaweedFS maps it to directories). Re-run `docker compose up s3-init` after adding more
files to pick them up without restarting the whole stack.

## Development mode

`make dev` runs the same nginx + S3 stack as `make start`, layered with
`docker-compose.dev.yml`. The source tree is bind-mounted into nginx and
`nginx/dev.conf` disables caching, so editing HTML/CSS/JS and refreshing
the browser always shows the latest files. Directory `index.html` routing
and `/media/*` proxying behave exactly as in production.

- Site: http://localhost:8080

## Linting and tests

Linters and tests run inside Docker containers — no local Node/Bun install required.

```sh
# build the images
docker compose -f docker-compose.build.yml build

# run an individual linter, or the test suite
docker compose -f docker-compose.build.yml run --rm lint-js
docker compose -f docker-compose.build.yml run --rm lint-css
docker compose -f docker-compose.build.yml run --rm lint-html
docker compose -f docker-compose.build.yml run --rm test
```
