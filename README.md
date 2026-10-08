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
make start   # build, then run the production-like stack (nginx serving _site/)
make stop    # stop it
make build   # build src/ into _site/ with Eleventy
make dev     # Eleventy dev server with live reload at http://localhost:8080
make format  # auto-fix JS/CSS style issues
make lint    # format, then run all linters (JS, CSS, HTML) in Docker
make test    # run the test suite with Bun, in Docker
make check   # lint + test
```

## Getting started

Pages and shared partials live in `src/` and are built into `_site/` by
[Eleventy](https://www.11ty.dev/) (`make build`). `src/_includes/base.html` is
the page layout; `src/_includes/partials/` holds the head, header, nav and
footer. Each page is plain HTML with a small front matter block (`layout`,
`title`). Output filenames match the source filenames (`src/about.html` becomes
`/about.html`).

### Adding images

Drop image files into `media-local/` (gitignored). Eleventy copies the folder
into `_site/media/`, so `media-local/photography/golden_hour/1415.jpg` is
served at `/media/photography/golden_hour/1415.jpg`, in dev and in the built
site alike.

## Development mode

`make dev` runs the Eleventy dev server in a container with the project
mounted, so edits to `src/`, `css/`, `static/` or `media-local/` rebuild the
site and the browser reloads itself. Press Ctrl-C to stop.

- Site: http://localhost:8080

`make start` is the production-like check: it builds `_site/` and serves it
with nginx.

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
