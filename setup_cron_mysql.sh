#!/bin/bash
set -e

# Путь к твоему backup-скрипту
BACKUP_SCRIPT="/home/toor/mysql_backup.sh"
LOG_FILE="/var/log/mysql_backup.log"

# Проверка, существует ли скрипт
if [ ! -f "$BACKUP_SCRIPT" ]; then
  echo "❌ Файл $BACKUP_SCRIPT не найден!"
  exit 1
fi

# Добавляем запись в cron (сначала удалим старую, если была)
(crontab -l 2>/dev/null | grep -v "$BACKUP_SCRIPT" ; echo "59 11 * * * $BACKUP_SCRIPT >> $LOG_FILE 2>&1") | crontab -

echo "Скрипт $BACKUP_SCRIPT добавлен в cron на 11:59 каждый день."
echo "Логи будут писаться в $LOG_FILE"