#!/bin/bash
set -e

# === Настройки ===
MYSQL_ROOT_PASSWORD="rootpass"
REPL_USER="repl_user"
REPL_PASSWORD="replpass"
MASTER_HOST="192.168.1.241"
SERVER_ID=2
BIND_ADDRESS="0.0.0.0"   # слушать все интерфейсы (можно указать IP слейва)

# === Установка MySQL ===
echo "Установка MySQL"
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

# === Настройка root-пароля ===
echo "Настройка root пользователя"
mysql --user=root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
