#!/bin/bash
set -e

if [ ! -f /var/www/html/config.php ]; then
    echo "Moodle ainda não instalado, pulando configuração de web services."
    exit 0
fi

echo "Habilitando web services (protocolo REST)..."
php /var/www/html/admin/cli/cfg.php --name=enablewebservices --set=1
php /var/www/html/admin/cli/cfg.php --name=webserviceprotocols --set=rest

php /docker-entrypoint.d/setup-webservices.php
