
## base image
# FROM php:7.4.24-apache as base
FROM php:8.1-apache as base

RUN apt-get update && apt-get upgrade -yy \
    && apt-get install -yy --no-install-recommends libjpeg-dev libpng-dev libwebp-dev \
    libzip-dev libfreetype6-dev supervisor zip \
    unzip software-properties-common sendmail \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-configure zip \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j "${NPROC}" gd \
    && docker-php-ext-install -j "${NPROC}" mysqli pdo pdo_mysql \
    && docker-php-ext-install zip opcache \
    && a2enmod rewrite

RUN echo "sendmail_path=/usr/sbin/sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini


ENV PS1="\u@\h:\w\\$ "
COPY --from=composer /usr/bin/composer /usr/bin/composer

ADD ./ops/build/php.ini /usr/local/etc/php/php.ini
ADD ./ops/build/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
ADD ./ops/build/apache.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www

RUN chown -R www-data:www-data /var/www/html

## Development image
FROM base as app-dev

RUN apt-get update && apt-get upgrade -yy \
    # && apt-get -yy install vim apt-transport-https=1.4.10 gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# wp cli, composer, node
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && echo "alias wp='wp --allow-root'" >> ~/.bashrc \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y git nodejs

RUN mkdir -p -m 777 /var/www/html/wp-content/languages

## NODE BUILD
FROM node:14-alpine as nodebuild

WORKDIR /var/www

ADD ./app /var/www
RUN apk add --no-cache python3 make g++ git
# RUN npm i --unsafe-perm && npm run build
RUN npm i
RUN npm run build
RUN npm prune --production
RUN rm -rf node_modules .babelrc *.js package* .gitignore




## PROD APP
FROM base as app-prod
COPY --from=nodebuild /var/www /var/www
RUN mkdir -m 775 /var/www/html/wp-content/cache
RUN chown -R www-data:www-data /var/www/html

RUN composer install

# PROD
FROM alpine:latest as prod-deploy
WORKDIR /app

RUN apk add --no-cache rsync openssh-client rsync sed
RUN mkdir -p /root/.ssh
RUN echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > /root/.ssh/config

COPY --from=app-prod /var/www/html ./web
COPY --from=app-prod /var/www/vendor ./vendor
COPY --from=app-prod /var/www/composer.json .
COPY --from=app-prod /var/www/composer.lock .

RUN chmod -R 755 .
# remove unnecessary files
RUN rm -rf wp-content/uploads wp-content/cache


FROM app-prod AS running
WORKDIR /var/www

