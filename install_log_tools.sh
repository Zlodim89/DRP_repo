#!/bin/bash
set -e

# Пути к скачанным .deb пакетам
ES_DEB="/home/toor/elasticsearch-8.19.1-amd64.deb"
KB_DEB="/home/toor/kibana-8.19.1-amd64.deb"
LS_DEB="/home/toor/logstash-8.19.1-amd64.deb"

# Проверяем наличие файлов
for pkg in "$ES_DEB" "$KB_DEB" "$LS_DEB"; do
    if [ ! -f "$pkg" ]; then
        echo "❌ Файл $pkg не найден!"
        exit 1
    fi
done

echo "Все deb пакеты найдены, начинаем установку."

# Установка Elasticsearch
sudo dpkg -i "$ES_DEB" || sudo apt-get install -f -y

# Установка Kibana
sudo dpkg -i "$KB_DEB" || sudo apt-get install -f -y

# Установка Logstash
sudo dpkg -i "$LS_DEB" || sudo apt-get install -f -y

echo "Elasticsearch, Kibana и Logstash установлены"

# Включаем автозапуск сервисов
sudo systemctl daemon-reexec
sudo systemctl enable elasticsearch.service
sudo systemctl enable kibana.service
sudo systemctl enable logstash.service