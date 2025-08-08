#!/bin/bash
set -e

echo "Установка MySQL 8 на чистую систему..."

# Проверка пользователя
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ Скрипт должен быть запущен от root (или через sudo)."
  exit 1
fi

# Установка зависимостей
apt update
apt install -y wget gnupg lsb-release debconf-utils

# Добавление репозитория MySQL 8
echo "Добавляем официальный репозиторий MySQL..."
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb
DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.29-1_all.deb

# Обновляем apt и устанавливаем MySQL Server
apt update
DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

# Запуск и автозапуск
systemctl enable mysql
systemctl start mysql

# Установка root-пароля и удаление ненужного
echo " Настройка root-пользователя и базовой безопасности..."
mysql_secure_installation <<EOF

y
rootpass
rootpass
y
y
y
y
EOF

echo "[*] Установка завершена. Версия MySQL:"
mysql --version

echo "MySQL установлен и запущен."
