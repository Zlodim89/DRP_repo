#!/bin/bash
set -e

ES_CONF="/etc/elasticsearch/elasticsearch.yml"
KB_CONF="/etc/kibana/kibana.yml"
LS_PIPELINE_DIR="/etc/logstash/conf.d"
LS_PIPELINE_CONF="$LS_PIPELINE_DIR/nginx-pipeline.conf"
ES_KEYTOOL="/usr/share/elasticsearch/bin/elasticsearch-keystore"

echo "Настраиваем Elasticsearch"

sudo bash -c "cat > $ES_CONF" <<EOF
cluster.name: elk-cluster
node.name: elk-node-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch

network.host: 0.0.0.0
http.port: 9200

discovery.type: single-node

# Отключаем безопасность
xpack.security.enabled: false
EOF

echo "Чистим Elasticsearch keystore от SSL-настроек"
for key in \
  xpack.security.transport.ssl.keystore.secure_password \
  xpack.security.transport.ssl.truststore.secure_password \
  xpack.security.http.ssl.keystore.secure_password \
  xpack.security.http.ssl.truststore.secure_password; do
    if sudo $ES_KEYTOOL list | grep -q "$key"; then
        echo "   ➡️ Удаляем $key"
        sudo $ES_KEYTOOL remove "$key"
    fi
done

echo "Настраиваем Kibana"

sudo bash -c "cat > $KB_CONF" <<EOF
server.host: "0.0.0.0"
server.port: 5601

elasticsearch.hosts: ["http://192.168.1.243:9200"]
EOF

echo "Настраиваем Logstash pipeline для получения nginx-логов"

sudo mkdir -p $LS_PIPELINE_DIR

sudo bash -c "cat > $LS_PIPELINE_CONF" <<EOF
input {
  beats {
    port => 5044
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
  }
  date {
    match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ]
    target => "@timestamp"
  }
}

output {
  elasticsearch {
    hosts => ["http://192.168.1.243:9200"]
    index => "nginx-logs-%{+YYYY.MM.dd}"
  }
  stdout { codec => rubydebug }
}
EOF

echo "Конфиги записаны"

echo "Перезапускаем сервисы"
sudo systemctl restart elasticsearch
sudo systemctl restart kibana
sudo systemctl restart logstash

echo "Elasticsearch: http://192.168.1.243:9200"
echo "Kibana:       http://192.168.1.243:5601"
echo "Logstash слушает на порту 5044 (ожидает Filebeat с 192.168.1.240)"
