#!/bin/bash
set -e

# Пути к пакетам (замените, если файлы лежат в другом месте)
GRAFANA_DEB="./grafana_12.1.1_16903967602_linux_amd64.deb"
PROMETHEUS_TAR="./prometheus-3.5.0.linux-amd64.tar.gz"

# 1. Установка Grafana
echo ">>> Устанавливаю Grafana..."
sudo apt-get update -y
sudo apt-get install -y adduser libfontconfig1 musl
sudo dpkg -i "$GRAFANA_DEB" || sudo apt-get install -f -y

sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# 2. Установка Prometheus
echo ">>> Устанавливаю Prometheus..."
TMP_DIR=/tmp/prometheus_setup
mkdir -p $TMP_DIR
tar -xvf "$PROMETHEUS_TAR" -C $TMP_DIR --strip-components=1

# Перемещаем бинарники
sudo mv $TMP_DIR/prometheus /usr/local/bin/
sudo mv $TMP_DIR/promtool /usr/local/bin/

# Директории и конфиги
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo mv $TMP_DIR/consoles /etc/prometheus/
sudo mv $TMP_DIR/console_libraries /etc/prometheus/

# Конфиг Prometheus
cat <<EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node_exporters"
    static_configs:
      - targets: ["192.168.1.241:9100", "192.168.1.242:9100"]
EOF

# Сервис для Prometheus
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus \\
  --web.listen-address=:9090 \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Запуск Prometheus
sudo systemctl daemon-reexec
sudo systemctl enable prometheus
sudo systemctl start prometheus

echo ">>> Установка завершена!"
echo "Grafana: http://localhost:3000 (логин: admin / пароль: admin)"
echo "Prometheus: http://localhost:9090"