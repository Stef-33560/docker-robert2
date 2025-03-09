ARG PHP_BASE_IMAGE
FROM ${PHP_BASE_IMAGE}

ARG ROBERT2_VERSION

LABEL maintainer="Maxime LAPLANCHE <maxime.laplanche@outlook.com>"

ENV ROBERT2_VERSION ${ROBERT2_VERSION}

ENV PHP_INI_DATE_TIMEZONE 'Europe/Paris'
ENV PHP_INI_MEMORY_LIMIT 256M
ENV TZ=Europe/Paris 

RUN mkdir -p /usr/src/php/ext/apcu && curl -fsSL        https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1

RUN apt-get update -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        libicu-dev \
        libxml2-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        openssl \
        && apt-get autoremove -y

# Pour Intl, créer le répertoire /conf.d s'il n'existe pas
RUN mkdir -p /conf.d && \
    docker-php-ext-configure intl && \
    docker-php-ext-install bcmath curl dom fileinfo gettext iconv intl xml && \
    docker-php-ext-install -j$(nproc) pdo_mysql

COPY php.ini /usr/src/php/php.ini
RUN a2enmod rewrite

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "Europe/Paris"\n' > /usr/local/etc/php/conf.d/tzone.ini

RUN curl -fLSso Loxya-${ROBERT2_VERSION}.zip https://github.com/Robert-2/Robert2/releases/download/${ROBERT2_VERSION}/Loxya-${ROBERT2_VERSION}.zip && \
    unzip Loxya-${ROBERT2_VERSION}.zip -d /tmp && \
    cp -r /tmp/Loxya-${ROBERT2_VERSION}/. /var/www/html/ && \
    rm -rf /tmp/* && \
    rm -rf Loxya-${ROBERT2_VERSION}.zip

RUN chown -R www-data:www-data /var/www && \
    chmod -R 777 /var/www/html/data && \
    chmod -R 777 /var/www/html/src/var && \
    chmod -R 777 /var/www/html/src/App/Config

RUN rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD ["apache2-foreground"]
