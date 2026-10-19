# Короткие команды для сайта denistv.com.
# `make` без аргументов печатает справку, `make dev` поднимает локальный сервер.

SHELL := /bin/bash

HUGO       ?= hugo
PORT       ?= 1313
BIND       ?= 127.0.0.1
BASEURL    ?= https://denistv.com/
HUGO_CACHE ?= $(CURDIR)/.hugo-cache
HUGO_FLAGS ?= --cacheDir "$(HUGO_CACHE)"

.DEFAULT_GOAL := help
.PHONY: help dev build check clean

help: ## Список команд
	@printf "Сайт denistv.com — доступные команды:\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
	@printf "\nПример: make dev PORT=1414\n"

dev: ## Локальный сервер с черновиками и live reload
	@command -v $(HUGO) >/dev/null || { printf "Hugo не найден. Установите: brew install hugo\n"; exit 1; }
	@if command -v lsof >/dev/null && lsof -nP -iTCP:$(PORT) -sTCP:LISTEN >/dev/null 2>&1; then \
		printf "\n  Порт %s уже занят:\n" "$(PORT)"; \
		lsof -nP -iTCP:$(PORT) -sTCP:LISTEN | awk 'NR > 1 {printf "    PID %s — %s\n", $$2, $$1}'; \
		printf "  Остановить: kill <PID>\n"; \
		printf "  Или другой порт: make dev PORT=%s\n\n" "$$(( $(PORT) + 1 ))"; \
		exit 1; \
	fi
	@printf "\n  Dev-сервер: http://localhost:%s\n  Остановить: Ctrl+C\n\n" "$(PORT)"
	$(HUGO) server --buildDrafts --buildFuture --navigateToChanged \
		--bind $(BIND) --port $(PORT) $(HUGO_FLAGS)

build: ## Собрать public/ как в CI: minify + gc
	@command -v $(HUGO) >/dev/null || { printf "Hugo не найден. Установите: brew install hugo\n"; exit 1; }
	$(HUGO) --minify --gc $(HUGO_FLAGS)

check: build ## Собрать и проверить sitemap, robots, 404, OG и JSON-LD
	@set -euo pipefail; \
	printf "Проверяю SEO-артефакты...\n"; \
	test -s public/sitemap.xml || { echo "  нет public/sitemap.xml"; exit 1; }; \
	grep -Fq "$(BASEURL)" public/sitemap.xml || { echo "  sitemap без baseURL"; exit 1; }; \
	test -s public/robots.txt || { echo "  нет public/robots.txt"; exit 1; }; \
	grep -Fq "Sitemap: $(BASEURL)sitemap.xml" public/robots.txt || { echo "  robots без ссылки на sitemap"; exit 1; }; \
	test -s public/404.html || { echo "  нет public/404.html"; exit 1; }; \
	test -s public/og.png || { echo "  нет public/og.png"; exit 1; }; \
	for page in index.html cv/index.html projects/index.html contacts/index.html; do \
		test -s "public/$$page" || { echo "  нет public/$$page"; exit 1; }; \
		grep -q 'application/ld+json' "public/$$page" || { echo "  нет JSON-LD: $$page"; exit 1; }; \
		grep -q 'og:image' "public/$$page" || { echo "  нет og:image: $$page"; exit 1; }; \
	done; \
	printf "OK: sitemap, robots, 404, обложка и разметка на месте\n"

clean: ## Удалить сборку и кеши
	@printf "Удаляю public/, resources/_gen/ и кеш Hugo...\n"
	rm -rf public resources/_gen .hugo_build.lock "$(HUGO_CACHE)"
