---
title: "Публикация"
description: "Как правка попадает на denistv.com: коммит, Actions, Pages."
weight: 30
---

## Короткий цикл

```bash
hugo --minify --gc
git add -A
git commit -m "Обновить страницу"
git push
```

Пуш в `main` запускает workflow `pages.yml`: Hugo собирает сайт и публикует
артефакт на GitHub Pages.

## Ручной запуск

Если нужно пересобрать без нового коммита: Actions → **Deploy Hugo site to
Pages** → **Run workflow**.

## Источник публикации

В `Settings → Pages → Source` должен быть выбран **GitHub Actions**. Режим
`Deploy from a branch` запускает встроенный Jekyll, который собирает ветку
целиком и перетирает результат Hugo.

## Домен и HTTPS

- `denistv.com` — четыре A-записи GitHub Pages;
- `www.denistv.com` — CNAME на `denistv.github.io`;
- TLS-сертификат выпускает GitHub через Let's Encrypt автоматически.

Проверить сертификат:

```bash
echo | openssl s_client -connect denistv.com:443 -servername denistv.com 2>/dev/null \
  | openssl x509 -noout -subject -dates
```

## Кеш

Страницы кешируются примерно на 10 минут. Если правка «не видна», откройте
адрес с параметром `?v=1` или подождите.
