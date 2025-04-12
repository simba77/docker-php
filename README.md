# Docker Compose setup for PHP Applications (docker-php) 

[Русская версия](README_RU.md)

Docker Compose setup for quick deployment of PHP applications.
The configuration supports development and production modes, using lightweight Alpine images to reduce container size.
Includes basic and optional services for convenient work.

### Key Features
- **Flexibility:** Easily configure services to suit the project needs.
- **Isolation:** Run multiple projects on one computer without conflicts.
- **Production-ready:** Built-in HTTPS support with Certbot.
- **Convenience:** Includes Composer, Redis, MariaDB, Ofelia and other useful tools.

## Contents

1.  [Included Services](#included-services)
2.  [Optional Services (for local development)](#optional-services-for-local-development)
3.  [Project Structure and Configuration](#project-structure-and-configuration)
4.  [Basic Commands](#basic-commands)
5.  [Service Configuration](#service-configuration)
6.  [SSL Certificates](#ssl-certificates)
7.  [Access to Sites by Domain Name](#access-to-sites-by-domain-name)
8.  [Restricting Access to Services](#restricting-access-to-services)
9.  [Additional Information](#additional-information)

## Included Services

- **Nginx**
- **PHP-FPM**
- **Composer**
- **Redis**
- **MariaDB**
- **Ofelia:** Task scheduler (cron).
- **Certbot:** Automatic retrieval of SSL certificates (for production).

## Optional Services (for local development)

- **Traefik:** HTTP proxy for domains.
- **Adminer:** Web interface for MariaDB.
- **MailHog:** Mail testing.

## Project Structure and Configuration

1. **Copy files:** Copy `.docker/`, `docker-compose.yml` and `makefile` from the project repository to the root of your project. `makefile` contains the basic commands for working with Docker Compose.
2. **Select configuration:** Copy `docker-compose.dev.yml` (for development) or `docker-compose.prod.yml` (for production) from the `.docker/` directory to `docker-compose.override.yml`, which should be located in the project root.

    ```bash
    cp .docker/docker-compose.dev.yml docker-compose.override.yml
    ```

3. **Configure SSL (for development and production):** Use the following command to copy the certificates. Ensure that the name of the **destination** folder matches the value of `APP_HOST` from `.env`.

    ```bash
    cp -R .docker/certbot/conf/live/test-app.loc .docker/certbot/conf/live/my-app.loc
    ```

4. **Remove unnecessary services:** Edit `docker-compose.yml` and `docker-compose.override.yml`, removing unnecessary services.
5. **Configure environment:** Edit the `.env` file.

## Basic Commands

* **Run:** `make up` or `docker compose up -d`
* **Stop:** `make stop` or `docker compose stop`
* **Rebuild:** `make rebuild` or `docker compose up -d --build`
* **PHP Console:** `make shell`

## Service Configuration

* **Nginx:** Configured via `default.conf.template` (for production) and `default.conf.dev.template` (for development), located in the `.docker/nginx/` directory.
* **PHP-FPM:**
    * PHP version is changed in `.docker/php-fpm/Dockerfile`.
    * General settings are in `.docker/php-fpm/app.ini`.
    * Configuration for prod version is in the file `.docker/php-fpm/app.prod.ini`.
    * Configuration for dev version is in the file `.docker/php-fpm/app.dev.ini`.
* **Ofelia:** Configured in `docker-compose.override.yml` via `labels`.

  Example configuration for running the `cli.php` script every minute:

    ```yaml
    ofelia.enabled: "true"
    ofelia.job-exec.php-cli.schedule: "@every 1m"
    ofelia.job-exec.php-cli.user: www-data
    ofelia.job-exec.php-cli.command: "php /app/public/cli.php"
    ```

## SSL Certificates

* **Obtain:** Use the following command to obtain SSL certificates. Replace `domain.com` and `www.domain.com` with your domain names.

    ```bash
    docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d domain.com -d www.domain.com
    ```

* **Update:** Use the following command to update expired SSL certificates.

    ```bash
    docker compose run --rm certbot renew
    ```

* **Automate:** Add the following task to cron for automatic certificate renewal. Replace `/home/user/project_path` with the path to your project.

    ```bash
    0 5 * * * cd /home/user/project_path && docker compose run --rm certbot renew
    ```

## Access to Sites by Domain Name

By default, your site will be accessible at `localhost:port`, where `port` is the port number specified in the `.env` file in the `NGINX_HTTP_PORT` and `NGINX_HTTPS_PORT` variables.

To access the site by domain name, you can use Traefik as a proxy server.

The domain by which your local site will be accessible is specified in the `.env` file in the `APP_HOST` and `NGINX_SERVER_NAME` variables.

In the `NGINX_SERVER_NAME` variable, you can specify multiple domains separated by a space.

For the site to be accessible in the browser, you need to add a line with the domain and IP address to the `hosts` file on your computer:

`127.0.0.1 test-app.loc`

Replace `test-app.loc` with your domain specified in the `.env` file.

More details on Traefik configuration can be found in the [traefik](traefik/README.md) directory.

**If you do not want to use Traefik, you will need to remove the `networks` section from `docker-compose.override.yml`:**

```yaml
networks:
  web:
    name: traefik_default
    external: true
```

## Restricting Access to Services

By default, in production mode, external access to mariadb and redis containers is restricted.
Depending on the network configuration, this restriction may not be necessary or may not work correctly.

In this case, remove 127.0.0.1: from docker-compose.override.yml for the respective services, but do not forget to restrict access to the ports, as this affects security.

## Additional Information

* Ofelia Documentation: [https://github.com/mcuadros/ofelia](https://github.com/mcuadros/ofelia)
* PHP Versions: [https://hub.docker.com/_/php/tags](https://hub.docker.com/_/php/tags)
