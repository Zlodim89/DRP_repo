#!/bin/bash
# Настройка MySQL Master для GTID репликации

MASTER_IP="192.168.1.241"   # IP мастера
REPL_USER="repl_user"
REPL_PASS="StrongPass123"

# Редактируем конфиг my.cnf
cat <<EOF >> /etc/mysql/mysql.conf.d/mysqld.cnf

# ===== Репликация (MASTER) =====
server-id=1
log_bin=mysql-bin
gtid_mode=ON
enforce_gtid_consistency=ON
binlog_format=ROW
log_slave_updates=ON
EOF

# Перезапускаем mysql
systemctl restart mysql

# Создаем пользователя для репликации
mysql -uroot -p -e "CREATE USER IF NOT EXISTS '${REPL_USER}'@'%' IDENTIFIED BY '${REPL_PASS}';"
mysql -uroot -p -e "GRANT REPLICATION SLAVE ON *.* TO '${REPL_USER}'@'%';"
mysql -uroot -p -e "FLUSH PRIVILEGES;"

echo "Master настроен. Репликационный пользователь: $REPL_USER / $REPL_PASS"
