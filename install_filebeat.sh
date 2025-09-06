#!/bin/bash

# Скрипт установки Filebeat для отправки логов Nginx в Logstash

ELK_LOGSTASH_SERVER="192.168.1.243"
LOGSTASH_PORT=5044
FILEBEAT_VERSION="8.x"

#echo "Устанавливаем репозиторий Elastic"
#wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
#sudo apt install -y apt-transport-https
#echo "deb https://artifacts.elastic.co/packages/${FILEBEAT_VERSION}/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-${FILEBEAT_VERSION}.list

echo "Устанавливаем Filebeat"
sudo apt install -y filebeat

echo "Отключаем блок output.elasticsearch в дефолтном конфиге"
sudo sed -i '/^output.elasticsearch:/,/^[^[:space:]]/ s/^/#/' /etc/filebeat/filebeat.yml

echo "Добавляем конфиг для чтения логов Nginx"
sudo tee -a /etc/filebeat/filebeat.yml > /dev/null <<EOF

# Конфигурация для чтения логов Nginx
filebeat.inputs:
- type: filestream
  enabled: true
  paths:
    - /var/log/nginx/*.log
  exclude_files: ['.gz$']
  prospector.scanner.exclude_files: ['.gz$']

# Отправка данных в Logstash
output.logstash:
  hosts: ["${ELK_LOGSTASH_SERVER}:${LOGSTASH_PORT}"]

EOF

echo "Перезапускаем и включаем Filebeat"
sudo systemctl daemon-reload
sudo systemctl enable filebeat
sudo systemctl restart filebeat

echo "Filebeat установлен и настроен для отправки логов Nginx на Logstash ${ELK_LOGSTASH_SERVER}:${LOGSTASH_PORT}."
