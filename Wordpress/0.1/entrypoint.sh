#!/bin/bash

set_var_if_null(){
	local varname="$1"
	if [ ! "${!varname:-}" ]; then
		export "$varname"="$2"
	fi
}

setup_httpd_log_dir(){
	test ! -d "$HTTPD_LOG_DIR" && echo "INFO: $HTTPD_LOG_DIR not found. creating ..." && mkdir -p "$HTTPD_LOG_DIR"
	chown -R www-data:www-data $HTTPD_LOG_DIR
}

setup_wordpress(){
	test ! -d "$WORDPRESS_HOME" && echo "INFO: $WORDPRESS_HOME not found. creating ..." && mkdir -p "$WORDPRESS_HOME"

	cd $WORDPRESS_HOME
	mv $WORDPRESS_SOURCE/wordpress.tar.gz $WORDPRESS_HOME/
	tar -xf wordpress.tar.gz -C $WORDPRESS_HOME/ --strip-components=1
	# create wp-config.php
	mv $WORDPRESS_SOURCE/wp-config.php.microsoft $WORDPRESS_HOME/wp-config.php

	rm $WORDPRESS_HOME/wordpress.tar.gz
	rm -rf $WORDPRESS_SOURCE

	chown -R www-data:www-data $WORDPRESS_HOME 
}

update_wordpress_config(){
	set_var_if_null "DATABASE_HOST" "localhost"
	set_var_if_null "DATABASE_NAME" "wordpress"
	set_var_if_null "DATABASE_USERNAME" "wordpress"
	set_var_if_null "DATABASE_PASSWORD" "MS173m_QN"
	set_var_if_null "TABLE_NAME_PREFIX" "wp_"
	if [ "${DATABASE_HOST,,}" = "localhost" ]; then
		export DATABASE_HOST="localhost"
	fi

	# update wp-config.php with the vars
        sed -i "s/connectstr_dbhost = '';/connectstr_dbhost = '$DATABASE_HOST';/" "$WORDPRESS_HOME/wp-config.php"
        sed -i "s/connectstr_dbname = '';/connectstr_dbname = '$DATABASE_NAME';/" "$WORDPRESS_HOME/wp-config.php"
        sed -i "s/connectstr_dbusername = '';/connectstr_dbusername = '$DATABASE_USERNAME';/" "$WORDPRESS_HOME/wp-config.php"
        sed -i "s/connectstr_dbpassword = '';/connectstr_dbpassword = '$DATABASE_PASSWORD';/" "$WORDPRESS_HOME/wp-config.php"
        sed -i "s/table_prefix  = 'wp_';/table_prefix  = '$TABLE_NAME_PREFIX';/" "$WORDPRESS_HOME/wp-config.php"
}

load_wordpress(){
        if ! grep -q "^Include conf/httpd-wordpress.conf" $HTTPD_CONF_FILE; then
                echo 'Include conf/httpd-wordpress.conf' >> $HTTPD_CONF_FILE
        fi
}

set -e

echo "INFO: DATABASE_HOST:" $DATABASE_HOST
echo "INFO: DATABASE_NAME:" $DATABASE_NAME
echo "INFO: DATABASE_USERNAME:" $DATABASE_USERNAME
echo "INFO: TABLE_NAME_PREFIX:" $TABLE_NAME_PREFIX

setup_httpd_log_dir
apachectl start

# That wp-config.php doesn't exist means WordPress is not installed/configured yet.
if [ ! -e "$WORDPRESS_HOME/wp-config.php" ]; then
	echo "INFO: $WORDPRESS_HOME/wp-config.php not found."
	echo "Installing WordPress for the first time ..."
	setup_wordpress
        update_wordpress_config
else
	echo "INFO: $WORDPRESS_HOME/wp-config.php already exists."
fi	

apachectl stop
# delay 2 seconds to try to avoid "httpd (pid XX) already running"
sleep 2s

echo "Loading WordPress conf ..."
load_wordpress

echo "Starting Apache httpd -D FOREGROUND ..."
apachectl start -D FOREGROUND
