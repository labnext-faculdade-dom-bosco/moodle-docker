#!/bin/bash
set -e

CONFIG_FILE=/var/www/html/config.php

if [ -f "$CONFIG_FILE" ]; then
    echo "Moodle já instalado (config.php existe), pulando instalação automática."
    exit 0
fi

echo "Aguardando o banco de dados (${MOODLE_DB_HOST})..."
until php -r "exit(@pg_connect('host=${MOODLE_DB_HOST} dbname=${MOODLE_DB_NAME} user=${MOODLE_DB_USER} password=${MOODLE_DB_PASSWORD}') ? 0 : 1);"; do
    sleep 2
done

echo "Instalando o Moodle via admin/cli/install.php..."
php /var/www/html/admin/cli/install.php \
    --non-interactive \
    --agree-license \
    --lang="${MOODLE_LANG}" \
    --wwwroot="${MOODLE_WWWROOT}" \
    --dataroot=/var/www/moodledata \
    --dbtype=pgsql \
    --dbhost="${MOODLE_DB_HOST}" \
    --dbname="${MOODLE_DB_NAME}" \
    --dbuser="${MOODLE_DB_USER}" \
    --dbpass="${MOODLE_DB_PASSWORD}" \
    --fullname="${MOODLE_SITE_FULLNAME}" \
    --shortname="${MOODLE_SITE_SHORTNAME}" \
    --adminuser="${MOODLE_ADMIN_USER}" \
    --adminpass="${MOODLE_ADMIN_PASSWORD}" \
    --adminemail="${MOODLE_ADMIN_EMAIL}"

chown www-data:www-data "$CONFIG_FILE"
echo "Instalação do Moodle concluída."
