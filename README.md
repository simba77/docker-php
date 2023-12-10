# docker-php

docker compose сборка для запуска практически любых приложений на php.

Сборка создавалась для локальной разработки. Основана на *-alpine образах и имеет небольшой вес.
Для работы в production режиме рекомендуется доработать самостоятельно под нужды проекта.

Сборка позволяет работать одновременно с несколькими проектами на одном компьютере избегая конфликтов в названии контейнеров и портов.

## Что включено в сборку?

- nginx
- php-fpm
- composer
- redis
- mariadb
- ofelia

Дополнительно вы можете использовать traefik и phpmyadmin

## Описание конфигурации

В качестве DOCUMENT_ROOT используется папка public т.к. большинство современных приложений используют эту папку в качестве корневой.
При необходимости вы можете изменить эту папку в конфиге nginx [localhost.conf](.docker%2Fnginx%2Fvhost%2Flocalhost.conf)

Если вам не нужны redis, mariadb или ofelia, то закомментируйте или удалите соответствующие блоки в [docker-compose.yml](docker-compose.yml)

Конфиг php расположен тут [php.ini](.docker%2Fphp-fpm%2Fphp.ini)

## Планировщик заданий

В качестве cron планировщика используется ofelia. Настраивается в файле docker-compose.yml в секции labels в нужном контейнере.
Пример можно посмотреть в контейнере php-fpm

```yaml
ofelia.enabled: "true"
ofelia.job-exec.php-cli.schedule: "@every 1m"
ofelia.job-exec.php-cli.user: www-data
ofelia.job-exec.php-cli.command: "php /app/public/cli.php"
```

С более подробной документацией можно ознакомиться в репозитории проекта [https://github.com/mcuadros/ofelia](https://github.com/mcuadros/ofelia).

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
