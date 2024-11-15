FROM php:8.3-fpm-alpine AS php_base

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gd opcache pdo_mysql zip intl redis exif

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY --link app.ini $PHP_INI_DIR/conf.d/

FROM php_base AS php_dev

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY --link app.dev.ini $PHP_INI_DIR/conf.d/

RUN apk --no-cache add shadow && usermod -u 1000 www-data

USER www-data
WORKDIR /app

FROM php_base AS php_prod

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY --link app.prod.ini $PHP_INI_DIR/conf.d/

RUN apk --no-cache add shadow && usermod -u 1000 www-data

USER www-data
WORKDIR /app