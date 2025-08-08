#!/bin/bash
set -e

# === Конфигурация ===
MYSQL_ROOT_PASS="rootpass"
WP_DB="wordpress"
WP_USER="wpuser"
WP_PASS="wppass"
BACKUP_FILE="/home/toor/wp_backup.sql"   # Путь к дампу
WP_PATH="/var/www/wordpress"

echo "Проверка наличия бэкапа..."
if [ ! -f "$BACKUP_FILE" ]; then
    echo "[ERROR] Бэкап $BACKUP_FILE не найден!"
    exit 1
fi

echo "Остановка сервисов..."
systemctl stop nginx || true
systemctl stop php*-fpm || true
systemctl stop mysql

echo "Запуск MySQL..."
systemctl start mysql

echo "Создание БД и пользователя (если нет)..."
mysql -u root -p"${MYSQL_ROOT_PASS}" <<EOF
CREATE DATABASE IF NOT EXISTS ${WP_DB} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${WP_USER}'@'%' IDENTIFIED BY '${WP_PASS}';
GRANT ALL PRIVILEGES ON ${WP_DB}.* TO '${WP_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "Импорт дампа..."
mysql -u root -p"${MYSQL_ROOT_PASS}" ${WP_DB} < "${BACKUP_FILE}"

echo "Настройка GTID master..."
cat >/etc/mysql/mysql.conf.d/gtid-master.cnf <<EOF
[mysqld]
server-id=1
log_bin=mysql-bin
binlog_format=ROW
gtid_mode=ON
enforce_gtid_consistency=ON
EOF

systemctl restart mysql

echo "Проверка состояния MySQL..."
mysql -u root -p"${MYSQL_ROOT_PASS}" -e "SHOW MASTER STATUS;"

echo "Запуск Nginx и PHP..."
systemctl start php*-fpm
systemctl start nginx

echo "Восстановление master из бэкапа завершено. Можно подключать slave."
