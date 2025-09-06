#!/bin/bash

# 1. Устанавливаем Nginx
echo "Устанавливаем nginx"
sudo apt update && sudo apt install -y nginx

# 2. Создаём новый конфиг для reverse proxy
NGINX_CONF="/etc/nginx/sites-available/reverse-proxy.conf"

echo "Создаём конфиг $NGINX_CONF"

sudo bash -c "cat > $NGINX_CONF" <<'EOF'
# Конфигурация reverse proxy с балансировкой нагрузки
upstream backend_servers {
    server 192.168.1.241;
    server 192.168.1.242;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 3. Включаем новый конфиг и выключаем дефолтный
echo "Включаем новый конфиг"
sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/reverse-proxy.conf
sudo rm -f /etc/nginx/sites-enabled/default

# 4. Проверяем конфиг на ошибки
echo "Проверяем конфигурацию nginx"
sudo nginx -t

# 5. Перезапускаем nginx
echo "Перезапускаем nginx"
sudo systemctl restart nginx

echo "Готово! Reverse proxy запущен"
