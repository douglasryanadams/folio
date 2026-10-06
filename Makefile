.PHONY: start stop dev format lint test check

start:
	docker compose up -d --build

stop:
	docker compose down --volumes

dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
	@echo "Dev server (no caching, source mounted): http://localhost:8080"

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
