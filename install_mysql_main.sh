#!/bin/bash
set -e

# === Настройки ===
MYSQL_ROOT_PASSWORD="rootpass"
REPL_USER="repl_user"
REPL_PASSWORD="replpass"
SERVER_ID=1
BIND_ADDRESS="192.168.1.241"

# === Установка MySQL ===
echo "Установка MySQL"
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

# === Чистим старый bind-address ===
echo "Убираем bind-address=127.0.0.1"
sudo sed -i 's/^[[:space:]]*bind-address\s*=.*$/# bind-address removed by replication setup/' /etc/mysql/mysql.conf.d/mysqld.cnf || true

# === Настройка my.cnf для мастера ===
echo "Настройка MySQL как MASTER"
sudo tee /etc/mysql/mysql.conf.d/99-replication.cnf > /dev/null <<EOF
[mysqld]
server-id=${SERVER_ID}
bind-address=${BIND_ADDRESS}

# Включаем бинарные логи
log_bin=/var/log/mysql/mysql-bin.log
binlog_expire_logs_seconds=604800
binlog_format=ROW

# Включаем GTID
gtid_mode=ON
enforce_gtid_consistency=ON

# Реплицируем все базы (кроме служебных)
binlog_do_db=   # пусто = все базы
EOF

# === Перезапуск MySQL ===
echo "Перезапуск MySQL"
sudo systemctl restart mysql

# === Настройка root-пароля и репликационного пользователя ===
echo "Настройка пользователей MySQL"
mysql --user=root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

mysql --user=root -p${MYSQL_ROOT_PASSWORD} <<EOF
CREATE USER IF NOT EXISTS '${REPL_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${REPL_PASSWORD}';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO '${REPL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "Конфигурация MASTER завершена!"
echo "----------------------------------------"
echo "Данные для реплики:"
echo "MASTER_HOST=${BIND_ADDRESS}"
echo "REPL_USER=${REPL_USER}"
echo "REPL_PASSWORD=${REPL_PASSWORD}"
echo "GTID используется: ON"
echo "----------------------------------------"
