# docker-php

docker compose сборка для запуска практически любых приложений на php.

Сборка создавалась для локальной разработки и для production режима. Основана на *-alpine образах и имеет небольшой вес.

Сборка позволяет работать одновременно с несколькими проектами на одном компьютере избегая конфликтов в названии
контейнеров и портов.

## Что включено в сборку?

- nginx
- php-fpm
- composer
- redis
- mariadb
- ofelia
- certbot

certbot используется только в production режиме и позволяет выпускать бесплатные SSL сертификаты от let's encrypt

Дополнительно для локальной разработки вы можете использовать traefik, adminer и mailhog

## Установка

Для установки в ваш проект, можете скопировать папку .docker, файл docker-compose.yml и makefile

Далее из папки .docker необходимо скопировать файл docker-compose.dev.yml или docker-compose.prod.yml, в зависимости от того, в каком режиме вы хотите развернуть проект, и переименовать итоговый файл в docker-compose.override.yml.

Пример команды для копирования:

```shell
cp .docker/docker-compose.dev.yml docker-compose.override.yml
```

Далее копируем папку с SSL сертификатом. Тут стоит обратить внимание, что итоговая папка должна иметь такое же название, как и значение переменной APP_HOST в .env файле.

```shell
cp -R .docker/certbot/conf/live/test-app.loc .docker/certbot/conf/live/my-app.loc
```

Далее вы можете удалить неиспользуемые сервисы из файлов docker-compose.yml и docker-compose.override.yml


## Описание конфигурации

### nginx

Есть 2 варианта конфигурации nginx и php - prod и dev.

Настройка nginx выполняется через шаблон. Версия для разработки настраивается в файле [default.conf.dev.template](.docker/nginx/default.conf.dev.template),
а версия для рабочего режима в файле [default.conf.template](.docker/nginx/default.conf.template)

В качестве DOCUMENT_ROOT используется папка public т.к. большинство современных приложений используют эту папку в
качестве корневой.
При необходимости вы можете изменить эту папку указанных выше файлах.


Конфиги php расположены тут [php-fpm](.docker/php-fpm)

Разбиение такое же на prod и dev. И есть общий конфиг app.ini, который работает в обоих режимах.

## Планировщик заданий

В качестве cron планировщика используется ofelia. Настраивается в файле docker-compose.override.yml в секции labels в нужном контейнере.
Пример можно посмотреть в контейнере php-fpm

```yaml
ofelia.enabled: "true"
ofelia.job-exec.php-cli.schedule: "@every 1m"
ofelia.job-exec.php-cli.user: www-data
ofelia.job-exec.php-cli.command: "php /app/public/cli.php"
```

С более подробной документацией можно ознакомиться в репозитории
проекта [https://github.com/mcuadros/ofelia](https://github.com/mcuadros/ofelia).

## Доступ к сайтам по доменному имени

По умолчанию ваш сайт будет доступен по адресу localhost:port где port - номер пора заданный в .env файле в переменной
NGINX_HTTP_PORT и NGINX_HTTPS_PORT.
Для доступа к сайту по домену можно использовать traefik в качестве прокси сервера.

Домен по которому будет доступен ваш локальный сайт задается в .env в переменной APP_HOST и NGINX_SERVER_NAME

В переменной NGINX_SERVER_NAME можно указать несколько доменов через пробел.

Чтобы сайт был доступен в браузере нужно добавить в файл hosts на вашем компьютере строку с доменом и ip

`127.0.0.1 test-app.loc`

test-app.loc замените на свой домен который указали в файле .env.

Подробнее с конфигурацией traefik можно ознакомиться в папке [traefik](traefik/README.md)

**Если вы не хотите использовать traefik, вам нужно будет удалить секцию networks из docker-compose.override.yml**

```yaml
networks:
  web:
    name: traefik_default
    external: true
```

## Запуск контейнеров для работы сайта

Для запуска можете использовать следующие команды

```shell
docker compose up -d
```

Для остановки

```shell
docker compose stop
```

Пересборка при изменении конфигурации

```shell
docker compose up -d --build
```

Если у вас установлена утилита make, то можете выполнять сокращенные команды

Запуск

```shell
make up
```

Остановка

```shell
make stop
```

Пересборка при изменении конфигурации

```shell
make rebuild
```

## Выполнение команд в контейнере php

Если вам нужно выполнить команды в контейнере, например, установить зависимости с помощью команды composer install или
выполнить любую другую команду можете выполнить команду

```shell
make shell
```

После выполнения команды откроется консоль внутри контейнера php-fpm в которой можете выполнять все необходимые команды.

В makefile так же доступны дополнительные команды которые могут вам пригодиться.

## Изменение версии php

Изменить версию php можно в этом файле: [Dockerfile](.docker%2Fphp-fpm%2FDockerfile)
В строке FROM php:8.2-fpm-alpine замените название образа на любой из доступных здесь https://hub.docker.com/_/php/tags
В большинстве случаев достаточно просто сменить цифру 8.2 на необходимую вам.

## Выпуск SSL сертификатов

Для выпуска сертификата используется команда:

```shell
docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ -d domain.com -d www.domain.com
```

после выполнения команды следуйте инструкциям.

Для перевыпуска сертификатов с истекшим сроком действия используется команда:

```shell
docker compose run --rm certbot renew
```

Для автоматизации перевыпуска ставим задание на крон:

`0 5 * * * cd /home/user/project_path && docker compose run --rm certbot renew`