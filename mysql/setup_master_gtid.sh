#!/bin/bash
set -e

echo "Настройка MySQL мастера с GTID"

# Включаем GTID в конфиге
cat <<EOF >> /etc/mysql/mysql.conf.d/mysqld.cnf

# --- GTID REPLICATION MASTER ---
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_format = ROW
gtid_mode = ON
enforce_gtid_consistency = ON
log_slave_updates = ON
binlog_expire_logs_seconds = 604800
EOF

# Перезапуск MySQL
systemctl restart mysql

# Создание пользователя для репликации
mysql -u root -p <<'SQL'
CREATE USER IF NOT EXISTS 'repluser'@'%' IDENTIFIED WITH mysql_native_password BY 'replpass';
GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'%';
FLUSH PRIVILEGES;
SQL

echo "Мастер готов для GTID репликации"
