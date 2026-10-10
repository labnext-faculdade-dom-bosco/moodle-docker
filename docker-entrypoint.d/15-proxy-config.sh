#!/bin/bash
set -e

CONFIG_FILE=/var/www/html/config.php

# O instalador só grava o wwwroot na primeira instalação; isto mantém o config.php igual ao .env.
sed -i -E "s|^(\\\$CFG->wwwroot[[:space:]]*=[[:space:]]*).*|\\1'${MOODLE_WWWROOT}';|" "$CONFIG_FILE"

# Atrás do Caddy o TLS termina fora do Moodle, então ele precisa saber que está em HTTPS.
case "$MOODLE_WWWROOT" in
    https://*)
        if ! grep -q 'CFG->sslproxy' "$CONFIG_FILE"; then
            sed -i "/^require_once(__DIR__ . '\/lib\/setup.php');/i \$CFG->sslproxy = true;" "$CONFIG_FILE"
        fi
        ;;
esac

chown www-data:www-data "$CONFIG_FILE"
