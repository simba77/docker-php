# Docker Compose для PHP-приложений (docker-php)

Docker Compose сборка для быстрого развертывания PHP-приложений.
Конфигурация поддерживает режимы разработки и продакшена, используя легковесные Alpine-образы для уменьшения размера контейнеров.
Включает основные и опциональные сервисы для удобной работы.

### Ключевые особенности
- **Гибкость:** Легко настраивайте сервисы под нужды проекта.
- **Изоляция:** Запускайте несколько проектов на одном компьютере без конфликтов.
- **Готовность к продакшену:** Встроенная поддержка HTTPS с Certbot.
- **Удобство:** Включает Composer, Redis, MariaDB, Ofelia и другие полезные инструменты.

## Содержание

1.  [Включенные сервисы](#включенные-сервисы)
2.  [Опциональные сервисы (для локальной разработки)](#опциональные-сервисы-для-локальной-разработки)
3.  [Структура проекта и настройка](#структура-проекта-и-настройка)
4.  [Основные команды](#основные-команды)
5.  [Конфигурация сервисов](#конфигурация-сервисов)
6.  [SSL-сертификаты](#ssl-сертификаты)
7.  [Доступ к сайтам по доменному имени](#доступ-к-сайтам-по-доменному-имени)
8.  [Дополнительная информация](#дополнительная-информация)


## Включенные сервисы

- **Nginx**
- **PHP-FPM**
- **Composer**
- **Redis**
- **MariaDB**
- **Ofelia:** Планировщик задач (cron).
- **Certbot:** Автоматическое получение SSL-сертификатов (для продакшена).

## Опциональные сервисы (для локальной разработки)

- **Traefik:** HTTP-прокси для доменов.
- **Adminer:** Веб-интерфейс для MariaDB.
- **MailHog:** Тестирование почты.

## Структура проекта и настройка

1.  **Копирование файлов:** Скопируйте `.docker/`, `docker-compose.yml` и `makefile` из репозитория проекта в корень вашего проекта. `makefile` содержит основные команды для работы с Docker Compose.
2.  **Выбор конфигурации:** Скопируйте `docker-compose.dev.yml` (для разработки) или `docker-compose.prod.yml` (для продакшена) из каталога `.docker/` в `docker-compose.override.yml`, который должен находиться в корне проекта.

    ```bash
    cp .docker/docker-compose.dev.yml docker-compose.override.yml
    ```

3.  **Настройка SSL (для разработки и продакшена):** Используйте следующую команду для копирования сертификатов. Убедитесь, что имя **конечной** папки соответствует значению `APP_HOST` из `.env`.

    ```bash
    cp -R .docker/certbot/conf/live/test-app.loc .docker/certbot/conf/live/my-app.loc
    ```

4.  **Удаление ненужных сервисов:** Отредактируйте `docker-compose.yml` и `docker-compose.override.yml`, удалив ненужные сервисы.
5.  **Настройка окружения:** Отредактируйте `.env` файл.

## Основные команды

* **Запуск:** `make up` или `docker compose up -d`
* **Остановка:** `make stop` или `docker compose stop`
* **Пересборка:** `make rebuild` или `docker compose up -d --build`
* **Консоль PHP:** `make shell`

## Конфигурация сервисов

* **Nginx:** Настраивается через `default.conf.template` (для продакшена) и `default.conf.dev.template` (для разработки), расположенные в каталоге `.docker/nginx/`.
* **PHP-FPM:**
    * Версия PHP изменяется в `.docker/php-fpm/Dockerfile`.
    * Общие настройки находятся в `.docker/php-fpm/app.ini`.
    * Конфигурация для prod версии находится в файле `.docker/php-fpm/app.prod.ini`.
    * Конфигурация для dev версии находится в файле `.docker/php-fpm/app.dev.ini`.
* **Ofelia:** Настраивается в `docker-compose.override.yml` через `labels`.

  Пример конфигурации для запуска скрипта `cli.php` каждую минуту:

    ```yaml
    ofelia.enabled: "true"
    ofelia.job-exec.php-cli.schedule: "@every 1m"
    ofelia.job-exec.php-cli.user: www-data
    ofelia.job-exec.php-cli.command: "php /app/public/cli.php"
    ```

## SSL-сертификаты

* **Получение:** Используйте следующую команду для получения SSL-сертификатов. Замените `domain.com` и `www.domain.com` на ваши доменные имена.

    ```bash
    docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d domain.com -d www.domain.com
    ```

* **Обновление:** Используйте следующую команду для обновления истекших SSL-сертификатов.

    ```bash
    docker compose run --rm certbot renew
    ```

* **Автоматизация:** Добавьте следующую задачу в cron для автоматического обновления сертификатов. Замените `/home/user/project_path` на путь к вашему проекту.

    ```bash
    0 5 * * * cd /home/user/project_path && docker compose run --rm certbot renew
    ```

## Доступ к сайтам по доменному имени

По умолчанию ваш сайт будет доступен по адресу `localhost:port`, где `port` — номер порта, заданный в `.env` файле в переменных `NGINX_HTTP_PORT` и `NGINX_HTTPS_PORT`.

Для доступа к сайту по доменному имени можно использовать Traefik в качестве прокси-сервера.

Домен, по которому будет доступен ваш локальный сайт, задается в `.env` файле в переменных `APP_HOST` и `NGINX_SERVER_NAME`.

В переменной `NGINX_SERVER_NAME` можно указать несколько доменов через пробел.

Чтобы сайт был доступен в браузере, нужно добавить в файл `hosts` на вашем компьютере строку с доменом и IP-адресом:

`127.0.0.1 test-app.loc`

Замените `test-app.loc` на ваш домен, указанный в файле `.env`.

Подробнее с конфигурацией Traefik можно ознакомиться в каталоге [traefik](traefik/README.md).

**Если вы не хотите использовать Traefik, вам нужно будет удалить секцию `networks` из `docker-compose.override.yml`:**

```yaml
networks:
  web:
    name: traefik_default
    external: true
```

## Дополнительная информация

* Документация Ofelia: [https://github.com/mcuadros/ofelia](https://github.com/mcuadros/ofelia)
* Версии PHP: [https://hub.docker.com/_/php/tags](https://hub.docker.com/_/php/tags)
