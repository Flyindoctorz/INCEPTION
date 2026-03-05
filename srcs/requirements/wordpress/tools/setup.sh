#!/bin/bash
set -e


# /run/secrets/ est monté par Docker

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

echo "Waiting for MariaDB to be ready..."
until mysql -h mariadb -u $MYSQL_USER -p$DB_PASSWORD -e "SELECT 1" &>/dev/null; do
    echo "MariaDB is unavailable - sleeping"
    sleep 3
done

echo "MariaDB is up - continuing..."

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Installing WordPress..."
    
    wp core download --allow-root
    
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$DB_PASSWORD \
        --dbhost=mariadb:3306 \
        --allow-root
    
    wp core install \
        --url=$DOMAIN_NAME \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
    
    wp user create $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --role=author \
        --allow-root
    
    echo "WordPress installation complete."
else
    echo "WordPress already installed."
fi

chown -R www-data:www-data /var/www/html
exec php-fpm7.4 -F