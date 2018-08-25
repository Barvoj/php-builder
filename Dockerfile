FROM php:alpine
MAINTAINER Vojtech Bartos <barvoj@seznam.cz>

# Configure Composer
ENV COMPOSER_CACHE_DIR /cache/composer
ENV COMPOSER_NO_INTERACTION 1

# Composer: make global packages available for execution
ENV PATH $PATH:/root/.composer/vendor/bin

ARG COMPOSER_VERSION=1.6.5
ARG COMPOSER_SHA256=67bebe9df9866a795078bb2cf21798d8b0214f2e0b2fd81f2e907a8ef0be3434

ARG PHPSTAN_VERSION=0.10.1
ARG PHPSTAN_SHA256=ffa8a0c436dd6c338d88bdf9fc8231a9a635186eacc9029a5ba484da34559cb7

RUN apk update && apk upgrade

# build dependencies
RUN apk add --no-cache --virtual .build-deps curl

RUN apk add --no-cache \
    nodejs \
    nodejs-npm \
    fcgi \
    zlib-dev \
    icu-dev \
    && docker-php-ext-install bcmath \
    mbstring \
    calendar \
    zip \
    intl

# Install gulp
RUN npm config set cache /cache/npm \
    && npm install --global gulp \
    && npm link gulp

# Install composer
RUN curl -Ls "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" > /usr/local/bin/composer \
    && test $(sha256sum /usr/local/bin/composer | cut -d ' ' -f 1) = ${COMPOSER_SHA256} \
    && chmod +x /usr/local/bin/composer

# Install phpstan
RUN curl -Ls "https://github.com/phpstan/phpstan/releases/download/${PHPSTAN_VERSION}/phpstan.phar" > /usr/local/bin/phpstan \
    && [ $(sha256sum /usr/local/bin/phpstan | cut -d ' ' -f 1) == ${PHPSTAN_SHA256} ] \
    && chmod +x /usr/local/bin/phpstan

# Composer speedup and tools
RUN composer global require hirak/prestissimo:@stable \
    "nette/tester=*" \
    "squizlabs/php_codesniffer=*" \
    "jakub-onderka/php-parallel-lint=*"

# remove build dependencies
RUN apk del .build-deps

