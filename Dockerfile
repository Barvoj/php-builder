FROM php:7.4-cli-alpine3.11
MAINTAINER Vojtech Bartos <barvoj@seznam.cz>

# Install modules
RUN apk update && apk upgrade \
    && apk add \
    icu-dev \
    git \
    unzip \
    wget \
    nodejs \
    nodejs-npm \
    && docker-php-ext-install bcmath calendar intl

# Instal composer
RUN export EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)" \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && export ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" \
    && if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then echo "Composer checksum invalid";  fi \
    && php composer-setup.php --install-dir /usr/local/bin \
    && php -r "unlink('composer-setup.php');" \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Install gulp
RUN npm config set cache /cache/npm \
    && npm install --global gulp \
    && npm link gulp
