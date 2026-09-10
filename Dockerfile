FROM moodlehq/moodle-php-apache:8.3-bookworm

ARG MOODLE_VERSION=5.2.2
ARG MOODLE_BRANCH=stable502

# Baixa o código-fonte oficial do Moodle na versão definida e o coloca no docroot padrão da imagem.
ADD https://download.moodle.org/download.php/direct/${MOODLE_BRANCH}/moodle-${MOODLE_VERSION}.tgz /tmp/moodle.tgz

RUN rm -rf /var/www/html/* \
    && tar -xzf /tmp/moodle.tgz -C /tmp \
    && cp -a /tmp/moodle/. /var/www/html/ \
    && rm -rf /tmp/moodle /tmp/moodle.tgz \
    && chown -R www-data:www-data /var/www/html

# Script que roda no start do container e instala o Moodle via CLI, sem precisar passar pelo instalador web.
COPY docker-entrypoint.d/10-install-moodle.sh /docker-entrypoint.d/10-install-moodle.sh

# Habilita web services, protocolo REST e deixa um token de admin pronto, para trabalhar com as APIs do Moodle.
COPY docker-entrypoint.d/20-enable-webservices.sh /docker-entrypoint.d/20-enable-webservices.sh
COPY docker-entrypoint.d/setup-webservices.php /docker-entrypoint.d/setup-webservices.php

RUN chmod +x /docker-entrypoint.d/10-install-moodle.sh /docker-entrypoint.d/20-enable-webservices.sh
