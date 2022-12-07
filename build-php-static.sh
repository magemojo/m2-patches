#!/bin/bash
U=${SUDO_USER:=${USER}}
if [[ -x `which realpath` ]]; then
	T=$(realpath ${BASH_SOURCE[0]:=${0}})
else
	T=${BASH_SOURCE[0]:=${0}}
fi
D=$(dirname ${T})

apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libfcgi-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libfcgi0ldbl;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libjpeg62-turbo-dbg;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libmcrypt-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libssl-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libc-client2007e;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libc-client2007e-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libxml2-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libbz2-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libcurl4-openssl-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libjpeg-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libpng12-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libfreetype6-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libkrb5-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libpq-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libxml2-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libtidy-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libmemcached-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install imagemagick-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install msgpack-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libonig-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libsodium-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install libzip-dev;
apt-get update && ACCEPT_EULA=Y apt-get -y --no-install-recommends install rsync;


PHP_VERSION=8.1.10
wget https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz -O php-${PHP_VERSION}.tar.bz2
tar -xzf php-${PHP_VERSION}.tar.bz2
cd ${D}/php-${PHP_VERSION}/ext
cd ..
rm configure
./buildconf --force
./configure --prefix=/srv/php --with-config-file-path=/srv/php --with-config-file-scan-dir=/srv/php.ini.d --localstatedir=/srv/php \
--config-cache --disable-cgi --enable-static= --enable-shared= --with-tsrm-pthreads --disable-phpdbg --disable-xdebug --enable-cli --enable-phar \
--with-msgpack --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/srv --enable-soap --with-pear=/srv/php \
--enable-calendar --with-curl --with-mcrypt --with-zlib --with-gd --without-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib \
--enable-sockets --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash --enable-zip --with-pcre-regex \
--with-pdo-mysql --without-pdo-pgsql --with-mysqli --enable-embedded-mysqli --with-jpeg-dir=/srv --with-png-dir=/srv --enable-gd-native-ttf --with-openssl \
--with-libdir=/srv/lib/x86_64-linux-gnu --enable-ftp --without-kerberos --without-imap --without-imap-ssl \
--enable-intl --with-pcre-jit --enable-apc --enable-apcu --with-curl --with-imagick --enable-memcached --enable-memcached-protocol --enable-memcached-msgpack --enable-memcached-msgpack \
--with-tidy --enable-shmop --with-gettext --with-xmlrpc --without-xsl --enable-opcache --enable-mcrypt --enable-redis --enable-gmp

make
make install

/srv/php/bin/pecl install mcrypt
/srv/php/bin/pecl install apcu
/srv/php/bin/pecl install gd
/srv/php/bin/pecl install gmp
/srv/php/bin/pecl install gnupg
/srv/php/bin/pecl install imagick
/srv/php/bin/pecl install imap
/srv/php/bin/pecl install readline
/srv/php/bin/pecl install redis
/srv/php/bin/pecl install sodium
/srv/php/bin/pecl install xls
/srv/php/bin/pecl install zip
/srv/php/bin/pecl channel-update pecl.php.net
/srv/php/bin/pecl install -f libsodium

for i in $(ldd /srv/php/bin/php | awk {'print $3'}); do rsync -L $i /srv/php/lib; done;
rsync -L /usr/lib/x86_64-linux-gnu/libsodium.so.23* /srv/php/lib
rsync -L /usr/lib/x86_64-linux-gnu/libzip.so.4* /srv/php/lib
rsync -L /usr/lib/libmcrypt.so.4* /srv/php/lib

cat <<EOT >> /srv/php/php.ini
[PHP]
memory_limit = 2048M
max_execution_time = 18000
max_input_vars = 100000
upload_max_filesize = 100M
post_max_size = 100M
date.timezone = UTC
sendmail_path = /usr/sbin/sendmail -t -i
session.gc_maxlifetime = 86400
sys_temp_dir = /tmp
user_ini.filename=""
extension="apcu.so"
extension="imagick.so"
extension="mcrypt.so"
extension="redis.so"
extension="sodium.so"
extension="zip.so"
zend_extension="opcache.so"
EOT
