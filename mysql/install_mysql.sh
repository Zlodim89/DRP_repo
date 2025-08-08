#!/bin/bash
set -e

ROOT_PASS="rootpass"

echo "Установка MySQL 8 на чистую систему..."

if [ "$(id -u)" -ne 0 ]; then
  echo "Скрипт должен быть запущен от root (или через sudo)."
  exit 1
fi

apt update
apt install -y wget gnupg lsb-release debconf-utils

echo "Добавляем официальный репозиторий MySQL..."
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb
echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.29-1_all.deb

apt update
DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

systemctl enable mysql
systemctl start mysql

echo "Меняем метод аутентификации root и задаём пароль..."

mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${ROOT_PASS}';
FLUSH PRIVILEGES;
EOF

echo "Установка завершена. Root-пароль: ${ROOT_PASS}"
