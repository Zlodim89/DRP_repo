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

# === Настройка my.cnf для SLAVE ===
echo "Настройка MySQL как SLAVE"
sudo tee /etc/mysql/mysql.conf.d/99-replication.cnf > /dev/null <<EOF
[mysqld]
server-id=${SERVER_ID}
bind-address=${BIND_ADDRESS}

# Включаем GTID
gtid_mode=ON
enforce-gtid-consistency=ON
EOF

# === Перезапуск MySQL ===
echo "[Перезапуск MySQL"
sudo systemctl restart mysql

# === Настройка root-пароля ===
echo "Настройка root пользователя"
mysql --user=root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# === Подключение к мастеру ===
echo "Подключение к мастеру (${MASTER_HOST})"
mysql --user=root -p${MYSQL_ROOT_PASSWORD} <<EOF
STOP REPLICA;
RESET REPLICA ALL;

CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='${MASTER_HOST}',
  SOURCE_USER='${REPL_USER}',
  SOURCE_PASSWORD='${REPL_PASSWORD}',
  SOURCE_AUTO_POSITION=1;

START REPLICA;
EOF

# === Проверка статуса реплики ===
echo "Статус репликации"
mysql --user=root -p${MYSQL_ROOT_PASSWORD} -e "SHOW REPLICA STATUS\G" | egrep 'Running|Auto_Position'
