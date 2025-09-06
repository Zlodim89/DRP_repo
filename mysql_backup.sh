#!/bin/bash

# MySQL connection settings
USER='repl_user'
PASS='replpass'

# Creating session
MYSQL="mysql --user=$USER --password=$PASS --skip-column-names"
MYSQLDUMP="/usr/bin/mysqldump"

# Path to backup directory
DIR="/tmp/backupdb"

# Create backup directory if it doesn't exist
mkdir -p "$DIR"

echo "Stopping replication..."
$MYSQL -e "STOP SLAVE;"

# Get list of databases
databases=$($MYSQL -e "SHOW DATABASES")

# Create a subdirectory for each database
for db in $databases; do
    mkdir -p "$DIR/$db"

# Get list of tables for each database
    tables=$($MYSQL -e "SHOW TABLES FROM \`$db\`")

# Dump the table and compress the output    
    for table in $tables; do
        echo "Dumping $db.$table..."
        $MYSQLDUMP --user="$USER" --password="$PASS" --set-gtid-purged=COMMENTED --master-data --opt "$db" "$table" | gzip -c > "$DIR/$db/$table.sql.gz"
    done
done

echo "Starting replication..."
$MYSQL -e "START SLAVE;"

echo "Backup completed in $DIR"