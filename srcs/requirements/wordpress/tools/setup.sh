#!/bin/bash
# setup_wordpress.sh
# Waits for MariaDB to be ready, then installs and configures WordPress
# (wp-config.php, core install, admin + author user creation)
# if not already done. Starts php-fpm at the end.

set -e

# Read secrets injected by Docker at runtime
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Wait until MariaDB accepts connections before proceeding
echo "Waiting for MariaDB to be ready..."
until mysql -h mariadb -u $MYSQL_USER -p$DB_PASSWORD -e "SELECT 1" &>/dev/null; do
    echo "MariaDB is unavailable - sleeping"
    sleep 3
done
echo "MariaDB is up - continuing..."

# Only install WordPress if the config file does not already exist
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Installing WordPress..."

    # Download the latest WordPress core files
    wp core download --allow-root

    # Generate wp-config.php with database credentials
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$DB_PASSWORD \
        --dbhost=mariadb:3306 \
        --allow-root

    # Run the WordPress installation (creates tables, sets site URL, title, admin)
    wp core install \
        --url=$DOMAIN_NAME \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root

    echo "WordPress installation complete."
fi

# Create author user if it does not exist yet
if ! wp user get $WP_USER --allow-root --path=/var/www/html &>/dev/null; then
    wp user create $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --role=author \
        --allow-root
    echo "User $WP_USER created."
fi

# Fix file ownership so php-fpm can read/write WordPress files
chown -R www-data:www-data /var/www/html

# Replace the current process with php-fpm (PID 1, foreground mode)
exec php-fpm7.4 -F