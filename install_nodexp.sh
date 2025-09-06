#!/bin/bash

# Обновляем пакеты
#echo "Обновляем пакеты"
#sudo apt update -y
#sudo apt upgrade -y

# Устанавливаем необходимые зависимости
echo "Устанавливаем зависимости"
sudo apt install -y wget tar

# Загружаем последнюю версию Node Exporter
echo "Скачиваем Node Exporter"
NODE_EXPORTER_VERSION="1.6.1" # Убедитесь, что это актуальная версия
wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz

# Распаковываем архив
echo "Распаковываем Node Exporter"
tar xvf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz

# Перемещаем бинарный файл в /usr/local/bin
echo "Перемещаем бинарный файл"
sudo mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin/

# Создаем пользователя для Node Exporter
echo "Создаем пользователя node_exporter"
sudo useradd -rs /bin/false node_exporter

# Устанавливаем Node Exporter как сервис
echo "Создаем сервис для Node Exporter"
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Перезагружаем systemd и запускаем сервис
echo "Перезагружаем systemd и запускаем сервис"
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Проверяем статус
echo "Проверка статуса сервиса"
sudo systemctl status node_exporter

# Успешное завершение
echo "Node Exporter успешно установлен и запущен!"
