#!/bin/bash

set -e

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "Initializing MariaDB database..."
    
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
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
    echo "MariaDB database already exists."
fi

exec mysqld --user=mysql --console
```

---

## 📁 srcs/requirements/nginx/Dockerfile

```dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=${DOMAIN_NAME:-login.42.fr}"

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]