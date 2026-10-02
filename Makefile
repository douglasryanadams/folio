.PHONY: start stop dev format lint test check

start:
	docker compose up -d

stop:
	docker compose down

dev:
	docker compose up -d s3 s3-init
	bun run dev

format:
	docker compose -f docker-compose.build.yml run --rm lint-js bun run format:js
	docker compose -f docker-compose.build.yml run --rm lint-css bun run format:css

lint: format
	docker compose -f docker-compose.build.yml run --rm lint-js
	docker compose -f docker-compose.build.yml run --rm lint-css
	docker compose -f docker-compose.build.yml run --rm lint-html

test:
	docker compose -f docker-compose.build.yml run --rm test

check: lint test
