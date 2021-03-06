FROM lsiobase/alpine.nginx:3.5
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# package version
ENV NEXTCLOUD_VER="11.0.3"

# environment settings
ENV NEXTCLOUD_PATH="/config/www/nextcloud"

# install build-dependencies
RUN \
 apk add --no-cache --virtual=build-dependencies \
	autoconf \
	automake \
	file \
	g++ \
	gcc \
	make \
	re2c \
	samba-dev \
	zlib-dev && \

 apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/community \
	php7-dev && \

# install runtime packages
 apk add --no-cache \
	curl \
	ffmpeg \
	libxml2 \
	samba \
	sudo \
	tar \
	unzip && \

 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/main \
	icu-libs \
	libwebp && \

 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/community \
	php7-apcu \
	php7-bz2 \
	php7-ctype \
	php7-curl \
	php7-dom \
	php7-exif \
	php7-ftp \
	php7-gd \
	php7-gmp \
	php7-iconv \
	php7-imap \
	php7-intl \
	php7-ldap \
	php7-mbstring \
	php7-mcrypt \
	php7-memcached \
	php7-pcntl \
	php7-pdo_mysql \
	php7-pdo_pgsql \
	php7-pdo_sqlite \
	php7-pgsql \
	php7-posix \
	php7-sqlite3 \
	php7-xml \
	php7-xmlreader \
	php7-zip && \

# fetch php smbclient source
 git clone git://github.com/eduardok/libsmbclient-php.git /tmp/smbclient && \

# compile smbclient
 cd /tmp/smbclient && \
 phpize7 && \
 ./configure \
	--with-php-config=/usr/bin/php-config7 && \
 make && \
 make install && \

# uninstall build-dependencies
 apk del --purge \
	build-dependencies && \

# configure php and nginx for nextcloud
 echo "extension="smbclient.so"" > /etc/php7/conf.d/00_smbclient.ini && \
 sed -i \
 's/;always_populate_raw_post_data = -1/always_populate_raw_post_data = -1/g' \
	/etc/php7/php.ini && \
 echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf && \

# cleanup
 rm -rf \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 443
VOLUME /config /data
