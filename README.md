# docker-php

docker compose сборка для запуска практически любых приложений на php.

Сборка создавалась для локальной разработки. Основана на *-alpine образах и имеет небольшой вес.
Для работы в production режиме рекомендуется доработать самостоятельно под нужды проекта.

Сборка позволяет работать одновременно с несколькими проектами на одном компьютере избегая конфликтов в названии
контейнеров и портов.

## Что включено в сборку?

- nginx
- php-fpm
- composer
- redis
- mariadb
- ofelia

Дополнительно вы можете использовать traefik и phpmyadmin

## Описание конфигурации

В качестве DOCUMENT_ROOT используется папка public т.к. большинство современных приложений используют эту папку в
качестве корневой.
При необходимости вы можете изменить эту папку в конфиге
nginx [localhost.conf](.docker%2Fnginx%2Fvhost%2Flocalhost.conf)

Если вам не нужны redis, mariadb или ofelia, то закомментируйте или удалите соответствующие блоки
в [docker-compose.yml](docker-compose.yml)

Конфиг php расположен тут [php.ini](.docker%2Fphp-fpm%2Fphp.ini)

## Планировщик заданий

В качестве cron планировщика используется ofelia. Настраивается в файле docker-compose.yml в секции labels в нужном
контейнере.
Пример можно посмотреть в контейнере php-fpm

```yaml
ofelia.enabled: "true"
ofelia.job-exec.php-cli.schedule: "@every 1m"
ofelia.job-exec.php-cli.user: www-data
ofelia.job-exec.php-cli.command: "php /app/public/cli.php"
```

С более подробной документацией можно ознакомиться в репозитории
проекта [https://github.com/mcuadros/ofelia](https://github.com/mcuadros/ofelia).

## Traefik. Доступ к сайтам по доменному имени

По умолчанию ваш сайт будет доступен по адресу localhost:port где port - номер пора заданный в .env файле в переменной
NGINX_HTTP_PORT и NGINX_HTTPS_PORT.
Для доступа к сайту по домену можно использовать traefik в качестве прокси сервера.

Принцип работы в данном случае будет примерно следующий:
Запускается traefik, он принимает все запросы к локальным доменам и проксирует их в нужный контейнер.

В данной сборке уже есть пример конфига для traefik [docker-compose-traefik.yml](docker-compose-traefik.yml)
Рекомендуется положить этот конфиг в свою папку отдельно от проекта предварительно переименовав в docker-compose.yml и
запустить контейнер.

Перед запуском контейнера потребуется создать сеть с именем traefik_default

```bash
docker network create traefik_default
```

Далее можно запустить контейнер с traefik

```bash
docker compose up -d
```

При перезапусках компьютера и докера он будет автоматически запускаться благодаря restart: always.
Если не хотите этого, просто измените указанный параметр.

Домен по которому будет доступен ваш локальный сайт задается в .env в переменной APP_HOST

Чтобы сайт был доступен в браузере нужно добавить в файл hosts на вашем компьютере строку с доменом и ip

`127.0.0.1 test-app.loc`

test-app.loc замените на свой домен который указали в файле .env.

**Если вы не хотите использовать traefik, вам нужно будет удалить секцию networks из основного docker-compose.yml**

```yaml
networks:
  web:
    name: traefik_default
    external: true
```

## Запуск

Для запуска можете использовать следующие команды

```bash
docker compose up -d
```

Для остановки

```bash
docker compose stop
```

Пересборка при изменении конфигурации

```bash
docker compose up -d --build
```

Если у вас установлена утилита make, то можете выполнять сокращенные команды

Запуск

```bash
make up
```

Остановка

```bash
make stop
```

Пересборка при изменении конфигурации

```bash
make rebuild
```
