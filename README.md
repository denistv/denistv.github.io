# denistv.com

Сайт на Hugo. Публикуется на GitHub Pages из репозитория
`denistv/denistv.github.io` через GitHub Actions.

## Локально

```bash
hugo server -D          # http://localhost:1313, черновики включены
hugo --minify --gc      # сборка в public/
```

Hugo 0.168.0 (extended). `public/` в git не коммитится.

## Структура

```
hugo.toml                      конфигурация, baseURL = https://denistv.com/
content/_index.md              главная страница
layouts/baseof.html            каркас документа
layouts/index.html             главная
layouts/_default/single.html   обычные страницы
static/css/style.css           стили, тёмная тема и print
static/favicon.svg             иконка
.github/workflows/pages.yml    сборка и деплой
```

## Публикация

1. Пуш в `main` запускает `.github/workflows/pages.yml`.
2. Source в Settings → Pages — **GitHub Actions**.
3. Домен `denistv.com` задан в Settings → Pages → Custom domain, файл `CNAME`
   в репозитории не нужен.

## Домен

- `denistv.com` — четыре A-записи GitHub Pages:
  `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`.
- `www.denistv.com` — CNAME на `denistv.github.io.`.
- DNS живёт в репозитории `services` (плейбук `ansible/playbooks/dns`), из этого
  репозитория не меняется.

TLS-сертификат выпускает GitHub через Let's Encrypt автоматически после привязки
домена к работающему сайту. Свой сертификат загрузить нельзя, `certbot` не нужен.
