#!/bin/bash
set -e

MYSQL_ROOT_PASS="rootpass"
REPL_USER="repluser"
REPL_PASS="replpass"
MASTER_IP="192.168.1.241"
WP_PATH="/var/www/wordpress"
SITE_DOMAIN="example.local"

echo "Настройка MySQL slave..."
cat >/etc/mysql/mysql.conf.d/gtid-slave.cnf <<EOF
[mysqld]
server-id=2
log_bin=mysql-bin
binlog_format=ROW
gtid_mode=ON
enforce_gtid_consistency=ON
EOF

systemctl restart mysql

echo "Импорт дампа..."
mysql -u root -p"${MYSQL_ROOT_PASS}" < /root/dump.sql

echo "Настройка подключения к master..."
mysql -u root -p"${MYSQL_ROOT_PASS}" <<EOF
STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO
  MASTER_HOST='${MASTER_IP}',
  MASTER_USER='${REPL_USER}',
  MASTER_PASSWORD='${REPL_PASS}',
  MASTER_AUTO_POSITION=1;
START SLAVE;
EOF

echo "Проверка репликации..."
mysql -u root -p"${MYSQL_ROOT_PASS}" -e "SHOW SLAVE STATUS\G" | grep "Slave_IO_Running\|Slave_SQL_Running"

echo "Установка Nginx и PHP..."
apt update
apt install -y nginx php-fpm php-mysql php-curl php-gd php-xml php-mbstring unzip wget

echo "Настройка прав доступа..."
chown -R www-data:www-data "${WP_PATH}"
chmod -R 755 "${WP_PATH}"

echo "Настройка Nginx..."
cat >/etc/nginx/sites-available/wordpress <<NGINX_CONF
server {
    listen 80;
    server_name ${SITE_DOMAIN};

    root ${WP_PATH};
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* \.(jpg|jpeg|png|gif|css|js|ico|xml)\$ {
        expires max;
        log_not_found off;
    }
}
NGINX_CONF

ln -sf /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo "Slave настроен и синхронизирован с master. WordPress готов к работе."
