#!/bin/bash
set -e

# Путь к целевому конфигу
TARGET_CONF="/etc/nginx/sites-available/load_balancer"

# Проверка наличия файла конфигурации
if [ ! -f ./nginx/load_balancer.conf ]; then
    echo "[!] Файл конфигурации load_balancer.conf не найден. Запустите из корня репозитория."
    exit 1
fi

# Копирование конфига
cp ./nginx/load_balancer.conf $TARGET_CONF

# Создание символической ссылки
ln -sf $TARGET_CONF /etc/nginx/sites-enabled/load_balancer

# Удаление дефолтного конфига, если он есть
rm -f /etc/nginx/sites-enabled/default

# Тест конфигурации и перезапуск
nginx -t && systemctl reload nginx

echo "Nginx сконфигурирован как балансировщик нагрузки."
