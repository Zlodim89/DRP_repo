#!/bin/bash
set -e

echo "Настройка и запуск Node Exporter..."

SERVICE_PATH="/etc/systemd/system/node_exporter.service"

# Копируем unit-файл
cp ./monitoring/node_exporter/node_exporter.service $SERVICE_PATH

# Перезапускаем systemd и включаем сервис
systemctl daemon-reload
systemctl enable --now node_exporter

echo "Node Exporter настроен и работает на порту 9100."
