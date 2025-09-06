#!/bin/bash
# Настройка MySQL Replica (Slave) для GTID репликации

MASTER_IP="192.168.1.241"   # IP мастера
REPL_USER="repl_user"
REPL_PASS="replpass"

# Редактируем конфиг my.cnf
cat <<EOF >> /etc/mysql/mysql.conf.d/mysqld.cnf

# ===== Репликация (SLAVE) =====
#server-id=2
#relay_log=relay-bin
#gtid_mode=ON
#enforce_gtid_consistency=ON
#binlog_format=ROW
#log_slave_updates=ON
#read_only=ON
#EOF

# Перезапускаем mysql
systemctl restart mysql

# Настройка репликации (MySQL 8.0+ синтаксис)
mysql -uroot -p <<MYSQL_SCRIPT
STOP REPLICA;
RESET REPLICA ALL;
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='${MASTER_IP}',
  SOURCE_USER='${REPL_USER}',
  SOURCE_PASSWORD='${REPL_PASS}',
  SOURCE_AUTO_POSITION=1;
START REPLICA;
MYSQL_SCRIPT

# Проверка статуса
mysql -uroot -p -e "SHOW REPLICA STATUS\G"
