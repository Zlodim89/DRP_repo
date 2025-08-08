#!/bin/bash
set -e

MYSQL_ROOT_PASS="rootpass"
REPL_USER="repluser"
REPL_PASS="replpass"

echo "Настройка MySQL master (GTID)..."
cat >/etc/mysql/mysql.conf.d/gtid-master.cnf <<EOF
[mysqld]
server-id=1
log_bin=mysql-bin
binlog_format=ROW
gtid_mode=ON
enforce_gtid_consistency=ON
EOF

systemctl restart mysql

echo "Создание пользователя для репликации..."
mysql -u root -p"${MYSQL_ROOT_PASS}" <<EOF
CREATE USER IF NOT EXISTS '${REPL_USER}'@'%' IDENTIFIED BY '${REPL_PASS}';
GRANT REPLICATION SLAVE ON *.* TO '${REPL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "Создание дампа базы с GTID..."
mysqldump --single-transaction --set-gtid-purged=ON -u root -p"${MYSQL_ROOT_PASS}" wordpress > /root/dump.sql

echo "Копирование дампа и файлов WordPress на slave..."
scp /root/dump.sql toor@192.168.1.242:/home/toor/dump.sql
rsync -avz /var/www/wordpress/ toor@192.168.1.242:/var/www/wordpress/

echo "Master настроен. Дамп и файлы переданы на slave."
