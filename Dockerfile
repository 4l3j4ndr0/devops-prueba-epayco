FROM php:7.3-apache

RUN apt-get update && apt-get install -y libssl-dev unzip \
    && rm -r /var/lib/apt/lists/*

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

WORKDIR /var/www/app

COPY composer.* ./
RUN mkdir -p tests database/seeds database/factories

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --prefer-dist --no-progress --no-ansi --no-interaction

COPY . .
COPY docker/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY docker/app.conf /etc/apache2/conf-enabled/z-app.conf
COPY docker/app.ini $PHP_INI_DIR/conf.d/app.ini

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN mkdir -p bootstrap/cache && chown -R www-data:www-data bootstrap/cache storage
RUN a2enmod rewrite
