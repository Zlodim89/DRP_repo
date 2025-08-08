#!/bin/bash
set -e

# === Конфигурация ===
MYSQL_ROOT_PASS="rootpass"
WP_DB="wordpress"
WP_USER="wpuser"
WP_PASS="wppass"
WP_PATH="/var/www/wordpress"
SITE_DOMAIN="example.local"

echo "Установка пакетов..."
apt update
apt install -y nginx mysql-server php-fpm php-mysql php-curl php-gd php-xml php-mbstring unzip wget

echo "Создание базы данных WordPress..."
mysql -u root -p"${MYSQL_ROOT_PASS}" <<EOF
CREATE DATABASE IF NOT EXISTS ${WP_DB} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${WP_USER}'@'%' IDENTIFIED BY '${WP_PASS}';
GRANT ALL PRIVILEGES ON ${WP_DB}.* TO '${WP_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "Загрузка и установка WordPress..."
wget -q https://wordpress.org/latest.zip -O /tmp/wordpress.zip
unzip -q /tmp/wordpress.zip -d /tmp
mkdir -p "${WP_PATH}"
cp -r /tmp/wordpress/* "${WP_PATH}/"

echo "Создание wp-config.php..."
cat >"${WP_PATH}/wp-config.php" <<EOF
<?php
define( 'DB_NAME', '${WP_DB}' );
define( 'DB_USER', '${WP_USER}' );
define( 'DB_PASSWORD', '${WP_PASS}' );
define( 'DB_HOST', 'localhost' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );
define( 'AUTH_KEY',         '$(openssl rand -base64 32)' );
define( 'SECURE_AUTH_KEY',  '$(openssl rand -base64 32)' );
define( 'LOGGED_IN_KEY',    '$(openssl rand -base64 32)' );
define( 'NONCE_KEY',        '$(openssl rand -base64 32)' );
define( 'AUTH_SALT',        '$(openssl rand -base64 32)' );
define( 'SECURE_AUTH_SALT', '$(openssl rand -base64 32)' );
define( 'LOGGED_IN_SALT',   '$(openssl rand -base64 32)' );
define( 'NONCE_SALT',       '$(openssl rand -base64 32)' );
\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF

echo "Настройка прав доступа..."
chown -R www-data:www-data "${WP_PATH}"
chmod -R 755 "${WP_PATH}"

echo "Настройка Nginx..."
cat >/etc/nginx/sites-available/wordpress <<NGINX_CONF
server {
    listen 80;
    server_name ${SITE_DOMAIN};

    root ${WP_PATH};
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* \.(jpg|jpeg|png|gif|css|js|ico|xml)\$ {
        expires max;
        log_not_found off;
    }
}
NGINX_CONF

ln -sf /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo "WordPress установлен на pr-backend-1. Перейдите по http://${SITE_DOMAIN} для завершения установки через веб-интерфейс."
