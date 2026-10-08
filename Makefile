.PHONY: build dev start stop logs format lint test check deploy deploy-dry-run pull-media

build:
	docker compose -f docker-compose.build.yml run --build --rm build

dev:
	@echo "Eleventy dev server (live reload, Ctrl-C to stop): http://localhost:8080"
	docker compose -f docker-compose.build.yml run --build --rm --service-ports dev

start: build
	docker compose up -d --build

stop:
	docker compose down --volumes

logs:
	docker compose -f docker-compose.yml logs -f


format:
	docker compose -f docker-compose.build.yml run --build --rm lint-js bun run format:js
	docker compose -f docker-compose.build.yml run --rm lint-css bun run format:css

lint: format
	docker compose -f docker-compose.build.yml run --rm lint-js
	docker compose -f docker-compose.build.yml run --rm lint-css
	docker compose -f docker-compose.build.yml run --rm lint-html

test:
	docker compose -f docker-compose.build.yml run --build --rm test

check: lint test

deploy:
	scripts/deploy.sh

deploy-dry-run:
	scripts/deploy.sh --dry-run

pull-media:
	scripts/pull-media.sh
