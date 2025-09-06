#!/bin/bash

set -e

# Настройки
DB_NAME=wordpress
DB_USER=wp_user
DB_PASS='StrongPassword123!'
DB_ROOT_PASS='rootpass'   # Убедись, что у тебя есть root-доступ к MySQL

WP_DIR=/var/www/html

# Установка зависимостей, если Apache и PHP ещё не установлены
echo "Установка Apache и PHP"
apt install -y apache2 php php-mysql libapache2-mod-php php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip unzip wget curl

# Проверка, что MySQL работает
echo "Проверка MySQL"
systemctl status mysql >/dev/null || { echo "❌ MySQL не работает!"; exit 1; }

# Создание базы данных и пользователя
echo "Создание базы данных и пользователя WordPress"
mysql -u root -p$DB_ROOT_PASS <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Скачивание и установка WordPress
echo "Скачивание WordPress"
wget https://wordpress.org/latest.zip -P /tmp
unzip -o /tmp/latest.zip -d /tmp

echo "Установка WordPress в $WP_DIR"
rm -rf $WP_DIR/*
cp -r /tmp/wordpress/* $WP_DIR

# Настройка wp-config.php
echo "Настройка wp-config.php"
cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php

sed -i "s/database_name_here/$DB_NAME/" $WP_DIR/wp-config.php
sed -i "s/username_here/$DB_USER/" $WP_DIR/wp-config.php
sed -i "s/password_here/$DB_PASS/" $WP_DIR/wp-config.php

# Настройка прав доступа
echo "Настройка прав на директорию"
chown -R www-data:www-data $WP_DIR
find $WP_DIR -type d -exec chmod 755 {} \;
find $WP_DIR -type f -exec chmod 644 {} \;

# Перезапуск Apache
echo "Перезапуск Apache"
systemctl enable apache2
systemctl restart apache2

echo "WordPress установлен!"
echo "Открой в браузере: http://<IP-сервера>"
