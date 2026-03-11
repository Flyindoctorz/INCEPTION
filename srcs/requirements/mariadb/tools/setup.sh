#!/bin/bash
# setup_mariadb.sh
# Initializes MariaDB: creates directories, sets permissions,
# bootstraps the database and user if not already present,
# then starts the MariaDB server.

set -e

# Create the runtime directory used by the MariaDB socket
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Create the log directory for MariaDB
mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# Read secrets injected by Docker at runtime
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Only initialize the database if it does not already exist
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "Initializing MariaDB database..."

    # Initialize the data directory with system tables
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Bootstrap: run SQL commands without starting a full server
    mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
    echo "MariaDB initialization complete."
else
    echo "MariaDB database already exists, skipping initialization."
fi

# Replace the current process with the MariaDB server (PID 1)
exec mysqld --user=mysql --console