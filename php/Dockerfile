FROM php:7.1-apache
# Customize container to match Drupal 8 requirements
RUN a2enmod rewrite
RUN apt-get update -y && apt-get install -y libpng-dev zip unzip mysql-client
RUN docker-php-ext-install gd opcache pdo pdo_mysql zip
# Install Node.js
ENV NODE_VERSION 8.5.0
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs
# Install Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer
ENV PATH /root/.composer/vendor/bin:$PATH
# Install Drush 8
RUN composer global require drush/drush:8.*
# Add our custom configuration
COPY php.ini /usr/local/etc/php/
COPY apache2.conf /etc/apache2/ame.conf
RUN echo "Include ame.conf" >> /etc/apache2/apache2.conf
# Use a custom docroot
ENV APACHE_DOCUMENT_ROOT /var/www/html/web
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
