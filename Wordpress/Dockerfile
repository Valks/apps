#
# Dockerfile for WordPress
#
FROM debian:jessie
MAINTAINER Valk


# ========
# ENV vars
# ========

# nginx
ENV NGINX_VERSION "1.12.0"
ENV NGINX_DOWNLOAD_URL "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"
ENV NGINX_DOWNLOAD_URL_ASC "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc"
ENV NGINX_SOURCE "/usr/src/nginx"
ENV NGINX_HOME "/usr/local/nginx"
ENV NGINX_CONF_DIR "$NGINX_HOME/conf"
ENV NGINX_CONF_FILE "$NGINX_CONF_DIR/nginx.conf"
ENV NGINX_LOG_DIR "/home/LogFiles/nginx"
ENV PATH "$NGINX_HOME/bin":$PATH

# php
ENV PHP_VERSION "7.1.2"
ENV PHP_DOWNLOAD_URL "https://secure.php.net/get/php-$PHP_VERSION.tar.gz/from/this/mirror"
ENV PHP_SHA256 "e6773217c9c719ca22abb104ae3d437d53daceaf31faf2e5eeb1f9f5028005d8"
ENV PHP_SOURCE "/usr/src/php"
ENV PHP_HOME "/usr/local/php"
ENV PHP_CONF_DIR "$PHP_HOME/etc"
ENV PHP_CONF_DIR_SCAN "$PHP_CONF_DIR/conf.d"
ENV PATH "$PHP_HOME/bin":$PATH

# wordpress
ENV WORDPRESS_VERSION "4.7.3"
ENV WORDPRESS_DOWNLOAD_URL "https://wordpress.org/wordpress-$WORDPRESS_VERSION.tar.gz"
ENV WORDPRESS_SHA1 "35adcd8162eae00d5bc37f35344fdc06b22ffc98"
ENV WORDPRESS_SOURCE "/usr/src/wordpress"
ENV WORDPRESS_HOME "/home/site/wwwroot"

#
ENV DOCKER_BUILD_HOME "/dockerbuild"


# ====================
# Download and Install
# 1. tools
# 2. apache httpd
# 3. mariadb
# 4. php
# 5. redis
# 6. phpmyadmin
# 7. wordpress
# ====================

WORKDIR $DOCKER_BUILD_HOME
RUN set -ex \
	# ------------------
	# 1. tools
	# ------------------
	&& tools=" \
		g++ \
		gcc \
		make \
		pkg-config \
		wget \
	" \
	&& apt-get update \
	&& apt-get install -y -V --no-install-recommends $tools \
	&& rm -r /var/lib/apt/lists/* \

	# ---------------
	# 2. nginx
	# ---------------
	&& mkdir -p $NGINX_SOURCE \
	&& mkdir -p $NGINX_HOME \
	## runtime and buildtime deps
	&& nginxBuildtimeDeps=" \
		ca-certificates \
		curl \
		libc-dev-bin \
		libc6-dev \
		libexpat1-dev \
		libfontconfig1-dev \
		libfreetype6-dev \
		libgd-dev \
		libgd2-dev \
		libgeoip-dev \
		libice-dev \
		libjbig-dev \
		libjpeg8-dev \
		liblzma-dev \
		libpcre3-dev \
		libperl-dev \
		libpng12-dev \
		libpthread-stubs0-dev \
		libsm-dev \
		libssl-dev \
		libtiff5-dev \
		libvpx-dev \
		libx11-dev \
		libxau-dev \
		libxcb1-dev \
		libxdmcp-dev \
		libxml2-dev \
		libxpm-dev \
		libxslt1-dev \
		libxt-dev \
		linux-libc-dev \
		manpages-dev \
		x11proto-core-dev \
		x11proto-input-dev \
		x11proto-kb-dev \
		xtrans-dev \
		zlib1g-dev \
		libpcre++-dev \
	" \
	&& nginxRuntimeDeps="\
		fontconfig-config \
		fonts-dejavu-core \
		geoip-database \
		init-system-helpers \
		libarchive-extract-perl \
		libexpat1 \
		libfontconfig1 \
		libfreetype6 \
		libgcrypt11 \
		libgd3 \
		libgdbm3 \
		libgeoip1 \
		libgpg-error0 \
		libjbig0 \
		libjpeg8 \
		liblog-message-perl \
		liblog-message-simple-perl \
		libmodule-pluggable-perl \
		libpng12-0 \
		libpod-latex-perl \
		libssl1.0.0 \
		libterm-ui-perl \
		libtext-soundex-perl \
		libtiff5 \
		libvpx1 \
		libx11-6 \
		libx11-data \
		libxau6 \
		libxcb1 \
		libxdmcp6 \
		libxml2 \
		libxpm4 \
		libxslt1.1 \
		perl \
		perl-modules \
		rename \
		sgml-base \
		ucf \
		xml-core \
	" \
	&& apt-get update \
	&& apt-get install -y -V --no-install-recommends $nginxBuildtimeDeps $nginxRuntimeDeps \		
	&& rm -r /var/lib/apt/lists/* \
	## download, validate, extract
	&& cd $DOCKER_BUILD_HOME \
	&& curl -SL "$NGINX_DOWNLOAD_URL" -o nginx.tar.gz \
	&& curl -SL "$NGINX_DOWNLOAD_URL_ASC" -o nginx.tar.gz.asc \
	&& gpg --verify nginx.tar.gz.asc \
	&& tar -xf nginx.tar.gz -C $NGINX_SOURCE --strip-components=1 \
	## configure, make, install
	&& cd $NGINX_SOURCE \
	&& ./configure \
		--user=www-data \
		--group=www-data \
		--prefix=$NGINX_HOME \
		### using prefork for PHP. see http://php.net/manual/en/install.unix.apache2.php
		--conf-path=$NGINX_CONF_FILE \
		--http-log-path=/proc/self/fd/1 \
		--error-log-path=/proc/self/fd/2 \
		--with-http_addition_module \
		--with-http_auth_request_module \
		--with-http_dav_module \
		--with-http_geoip_module \
		--with-http_gzip_static_module \
		--with-http_image_filter_module \
		--with-http_perl_module \
		--with-http_realip_module \
		--with-http_spdy_module \
		--with-http_ssl_module \
		--with-http_stub_status_module \
		--with-http_sub_module \
		--with-http_xslt_module \
		--with-ipv6 \
		--with-mail \
		--with-mail_ssl_module \
		--with-pcre-jit \
	&& make -j "$(nproc)" \
	&& make install \
	&& make clean \
	## clean up
	&& rm -rf $NGINX_SOURCE \
		$NGINX_HOME/man \
		$NGINX_HOME/manual \
	&& rm $DOCKER_BUILD_HOME/nginx.tar.gz \
	&& apt-get purge -y -V -o APT::AutoRemove::RecommendsImportant=false --auto-remove $nginxBuildtimeDeps \

	# ------
	# 4. php
	# ------
	### see http://php.net/manual/en/install.unix.apache2.php
	### see http://linuxfromscratch.org/blfs/view/svn/general/php.html
	&& mkdir -p $PHP_SOURCE \
	&& mkdir -p $PHP_HOME \
	## buildtime deps
	### libbz2-dev >> --with-bz2 >> [phpmyadmin] Bzip2 compression and decompression requires functions (bzopen, bzcompress) which are unavailable on this system.
	### libgmp-dev >> --with-gmp
	### libicu-dev >> --enable-intl
	### libldap2-dev >> --with-ldap
	&& phpBuildtimeDeps="\
		libbz2-dev \
		libgmp-dev \
		libicu-dev \
		libldap2-dev \
		libssl-dev \
		libxml2-dev \
	" \
	## runtime deps
	### libcurl4-gnutls-dev >> --with-curl >> [wordpress] download plugins
	### libjpeg-dev, libpng12-dev >> --with-gd, --with-jpeg-dir, --with-png-dir (libpng12-dev >> zlib1g-dev)
	### zlib1g-dev >> --with-zlib >> [wordpress] Uncaught Error: Call to undefined function gzinflate() in /var/www/wp-includes/class-requests.php:947
	&& phpRuntimeDeps=" \
		libcurl4-openssl-dev \
		libjpeg-dev \
		libpng12-dev \
		libxml2 \
	" \
	&& apt-get update \
	&& apt-get install -y -V --no-install-recommends $phpBuildtimeDeps $phpRuntimeDeps \	
	&& rm -rf /var/lib/apt/lists/* \
	&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
	&& ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
	&& ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
	## download, validate, extract
	&& cd $DOCKER_BUILD_HOME \
	&& wget -O php.tar.gz "$PHP_DOWNLOAD_URL" --no-check-certificate \
	&& echo "$PHP_SHA256 *php.tar.gz" | sha256sum -c - \
	&& tar -xf php.tar.gz -C $PHP_SOURCE --strip-components=1 \	
	## configure, make, install
	&& cd $PHP_SOURCE \
	&& ./configure \
		--prefix=$PHP_HOME \
		### we don't need CGI version of PHP here
		--disable-cgi \
		### also, don't need pdo
		--disable-pdo \
		### use fpm (nginx)
		--enable-fpm \
		--with-fpm-user=www-data \
		--with-fpm-group=www-data \
		--enable-bcmath \
		--enable-intl \
		--enable-mbstring \
		--enable-zip \
		--with-apxs2=$NGINX_HOME/bin/apxs \
		--with-bz2 \
		--with-config-file-path=$PHP_CONF_DIR \
		--with-config-file-scan-dir=$PHP_CONF_DIR_SCAN \
		--with-curl \
		--with-gd \
		--with-jpeg-dir \
		--with-png-dir \
		--with-gmp \
		--with-ldap \
		### see http://php.net/manual/en/mysqlnd.overview.php
		### see http://php.net/manual/en/mysqlinfo.api.choosing.php
		--with-mysqli=mysqlnd \
		--with-openssl \
		### Extras
		--enable-soap \
		--with-zlib \
	&& make -j "$(nproc)" \
	&& make install \
	&& make clean \
	## clean up
	&& rm -rf $PHP_SOURCE \
	&& rm -rf $PHP_HOME/php/man \
	&& rm $DOCKER_BUILD_HOME/php.tar.gz \
	&& apt-get purge -y -V -o APT::AutoRemove::RecommendsImportant=false --auto-remove $phpBuildtimeDeps \

	# ------------	
	# 7. wordpress
	# ------------
	&& mkdir -p $WORDPRESS_SOURCE \
	&& cd $WORDPRESS_SOURCE \
	&& wget -O wordpress.tar.gz "$WORDPRESS_DOWNLOAD_URL" --no-check-certificate \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \

	# ----------
	# ~. clean up
	# ----------
	&& apt-get purge -y -V -o APT::AutoRemove::RecommendsImportant=false --auto-remove $tools \
	&& apt-get autoremove -y


# =========
# Configure
# =========

# httpd confs
COPY httpd.conf $NGINX_CONF_DIR/
COPY httpd-modules.conf $NGINX_CONF_DIR/
COPY httpd-php.conf $NGINX_CONF_DIR/
COPY httpd-wordpress.conf $NGINX_CONF_DIR/
# php confs
COPY php.ini $PHP_CONF_DIR/
COPY php-opcache.ini $PHP_CONF_DIR_SCAN/
# wordpress conf
COPY wp-config.php.microsoft $WORDPRESS_SOURCE/

RUN set -ex \
	## include php.conf
	&& echo 'Include conf/httpd-php.conf' >> $NGINX_CONF_FILE \
    ##
	&& test ! -d /var/lib/php/sessions && mkdir -p /var/lib/php/sessions \
	&& chown www-data:www-data /var/lib/php/sessions \
	##
	&& test ! -d /var/www && mkdir -p /var/www \
        && echo '<html><head><meta http-equiv="refresh" content="30" /><meta http-equiv="pragma" content="no-cache" /><meta http-equiv="cache-control" content="no-cache" /><title>Installing WordPress</title></head><body>Installing WordPress ... This could be done in minutes. Please refresh your browser later.</body></html>' > /var/www/index.html \
        && chown -R www-data:www-data /var/www \
	##
	&& ln -s $WORDPRESS_HOME /var/www/wordpress \
	##
	&& rm -rf /var/log/httpd \
	&& ln -s $NGINX_LOG_DIR /var/log/httpd


# =====
# final
# =====
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
EXPOSE 80
ENTRYPOINT ["entrypoint.sh"]
