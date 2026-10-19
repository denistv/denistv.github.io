# Сайт на Hugo

Статический сайт на [Hugo](https://gohugo.io/) без внешней темы: свои шаблоны,
свой CSS. Собирается в GitHub Actions и публикуется на GitHub Pages по адресу
`https://denistv.com/`.

## Требования

- Hugo **extended** 0.168.0 — та же версия зафиксирована в
  `.github/workflows/pages.yml` (`env.HUGO_VERSION`). Локальная и CI-версии должны
  совпадать, иначе шаблон может собраться локально и упасть в CI.
- git и доступ к `git@github.com:denistv/denistv.github.io.git` по SSH.

Установка на macOS:

```bash
brew install hugo
hugo version   # ожидаемо: hugo v0.168.0+extended
```

## Быстрый старт

```bash
make dev                  # http://localhost:1313, черновики и live reload
make build                # разовая сборка в public/, как в CI
make check                # сборка + проверка sitemap, robots, 404, OG и JSON-LD
make                      # справка по командам
```

`make dev` пересобирает страницу при сохранении файлов и после перезагрузки
открывает изменённую страницу. Порт можно переопределить: `make dev PORT=1414`.
Если порт уже занят, команда покажет PID и предложит соседний порт.

Без make те же команды выглядят так:

```bash
hugo server -D
hugo --minify --gc
```

## Структура

```
hugo.toml                          конфигурация: baseURL, язык, меню, TOC
Makefile                           короткие команды: dev, build, check, clean
content/_index.md                  главная
content/cv.md                      страница CV
themes/rungpt/layouts/             шаблоны темы: baseof, главная, single
themes/rungpt/assets/css/main.css  токены дизайн-системы и все стили
themes/rungpt/assets/js/site.js    мобильное меню и подсветка TOC
themes/rungpt/static/fonts/        self-hosted Plus Jakarta Sans
static/favicon.svg                 иконка сайта
.github/workflows/pages.yml        сборка и деплой на Pages
CNAME                              домен для Pages
```

Важно: содержимое `static/` (например `static/favicon.svg`) публикуется в корень
сайта. Файлы из корня репозитория на сайт не копируются — стили и шаблоны живут
в `themes/rungpt/`.

## Контент

Главная — `content/_index.md`. Front matter в формате YAML:

```yaml
---
title: "Заголовок страницы"
description: "Описание для meta description"
draft: true          # черновик: не попадёт в сборку без -D
---
```

Тело — обычный Markdown: заголовки `##`/`###`, списки, ссылки, таблицы.
Заголовок `title` выводится шаблоном, поэтому `# H1` в теле не нужен — иначе
заголовок продублируется.

Новая страница — просто новый файл:

```bash
content/about.md   →  /about/
```

Черновики видны только в `hugo server -D`. Перед пушем черновик либо заполняется,
либо получает `draft: false`.

Картинки кладите в `static/` (например `static/photo.jpg`) и ссылайтесь как
`/photo.jpg`. Указывайте `alt` и сжимайте файлы — репозиторий публичный.

## Шаблоны

`layouts/baseof.html` — общий каркас, страницы подставляют содержимое в блок:

```go-html-template
{{ define "main" }}
  <article class="page">
    {{ .Content }}
  </article>
{{ end }}
```

Что используется:

- `{{ .Content }}` — отрендеренный Markdown страницы;
- `{{ .Title }}`, `{{ .Description }}`, `{{ .Permalink }}` — данные страницы;
- `{{ site.Title }}`, `{{ site.Params.* }}` — данные из `hugo.toml`;
- `{{ "css/style.css" | relURL }}` — ссылка, работающая и на домене, и на
  `github.io`, и локально.

Если нужен повторяющийся фрагмент — `layouts/partials/name.html` и вызов
`{{ partial "name.html" . }}`.

## Стили

Один файл `static/css/style.css`, без препроцессоров и внешних шрифтов
(системный стек шрифтов). Цвета — CSS-переменные в `:root`, тёмная тема
включается через `@media (prefers-color-scheme: dark)`.

При правках проверяйте три режима:

1. узкий экран (≤ 30rem);
2. тёмная тема;
3. печать: `Cmd+P` в браузере — ссылки должны быть читаемы, разрывы страниц
   не должны рвать блоки.

## Сборка

```bash
make build        # то же, что hugo --minify --gc
```

- `--minify` — минификация HTML/CSS/JS;
- `--gc` — очистка неиспользуемого кеша ресурсов.

`make check` собирает сайт и дополнительно проверяет, что в `public/` попали
sitemap, robots.txt, страница 404, OG-обложка и JSON-LD на всех страницах.

Результат — в `public/`. Каталог в `.gitignore` и **не коммитится**: артефакт
создаёт CI.

## Публикация

1. Коммит и пуш в `main`:

   ```bash
   git add -A
   git commit -m "Обновить страницу"
   git push
   ```

2. Запускается `.github/workflows/pages.yml`:
   `checkout` → установка Hugo → `hugo --minify --gc` → `upload-pages-artifact` →
   `deploy-pages`.
3. Source в **Settings → Pages** должен быть **GitHub Actions**. Если стоит
   `Deploy from a branch`, GitHub дополнительно собирает ветку Jekyll-ем и
   перетирает результат Hugo.
4. Custom domain — `denistv.com` (задан в настройках Pages). Файл `CNAME`
   в репозитории для Actions-деплоя не обязателен.

Ручной запуск без нового коммита: Actions → **Deploy Hugo site to Pages** →
**Run workflow** (`workflow_dispatch`).

## Домен и HTTPS

- `denistv.com` (apex) — только четыре A-записи:
  `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`.
  Лишние A/AAAA ломают выпуск сертификата.
- `www.denistv.com` — CNAME на `denistv.github.io.`.
- DNS живёт в отдельном репозитории `services`; из этого репозитория не меняется.
- TLS выпускает GitHub через Let's Encrypt автоматически. Свой сертификат
  загрузить нельзя, `certbot` не нужен. После выпуска включается `Enforce HTTPS`.

Проверка:

```bash
echo | openssl s_client -connect denistv.com:443 -servername denistv.com 2>/dev/null \
  | openssl x509 -noout -subject -dates -ext subjectAltName
curl -I https://denistv.com/
```

## Диагностика

| Симптом | Причина и что делать |
|---|---|
| Сборка падает на `Build` | смотреть лог шага; чаще всего синтаксис шаблона или front matter |
| На сайте 404 после пуша | Pages не включён, или Source = `Deploy from a branch`, или деплой ещё идёт |
| Правка не видна | кеш Pages `max-age=600`; открыть с `?v=1` или подождать 10 минут |
| Ссылки ведут на `localhost` | в `hugo.toml` сломан `baseURL`; должен быть `https://denistv.com/` |
| Ошибка сертификата | домен не привязан к сайту, или появились лишние A/AAAA |
| `WARN deprecated` | обновить ключ конфига под текущую версию Hugo (например `languageCode` → `locale`) |

`hugo --minify --gc` перед пушем ловит большинство проблем локально.

## Правила

- Не коммитить `public/` и не деплоить вручную поверх Actions.
- Не менять `baseURL` без одновременной правки настроек Pages.
- Не добавлять секреты, токены и лишние персональные данные — репозиторий публичный.
- Не пушить force в `main`; откат — через `git revert`.
- Не подключать аналитику, трекеры и внешние шрифты без отдельного решения.
