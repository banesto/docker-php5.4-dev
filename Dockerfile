FROM centos:6

RUN \
  yum -y update && \
  yum -y install \
    git \
    httpd \
    mod_perl \
    nano \
    rsync \
    ruby \
    vsftpd \
    wget

RUN \
  yum -y install ntp && \
  rm -rf /etc/localtime && \
  ln -s /usr/share/zoneinfo/EET /etc/localtime

# RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
RUN rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
# RUN yum search php

RUN \
  yum -y install \
    php55w \
    php55w-fpm \
    php55w-mbstring \
    php55w-cli \
    php55w-gd \
    php55w-mysql \
    php55w-devel \
    php55w-pecl-memcache \
    php55w-pspell \
    php55w-snmp \
    php55w-xmlrpc \
    php55w-xml \
    php55w-pear

RUN \
  yum -y install rubygems && \
  gem install sass --no-rdoc --no-ri && \
  gem install bundler --no-rdoc --no-ri

RUN \
  yum -y install gcc-c++ && \
  wget http://nodejs.org/dist/v0.10.4/node-v0.10.4.tar.gz && \
  tar zxf node-v0.10.4.tar.gz && \
  cd node-v0.10.4 && \
  ./configure && \
  make && \
  make install && \
  npm cache clean -f && \
  npm install -g n && \
  n stable && \
  npm install -g grunt-cli

  # delete source folder & archive? test if nothing fails after that
RUN \
  yum -y install \
    mysql-server \
    mysql && \
  chkconfig --levels 235 mysqld on

ENV \
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8 \
  LEAF_DEVELOPMENT=1

# -----------------------------------------------------------------------------
# Apache configuration fixes
# -----------------------------------------------------------------------------

RUN sed -i \
  -e 's~^Timeout \(.*\)$~Timeout 120~g' \
  -e 's~^#ServerName \(.*\)$~ServerName 0.0.0.0:80~g' \
  -e 's~^DirectoryIndex \(.*\)$~DirectoryIndex index.html index.html.var index.php~g' \
  -e 's~^#EnableSendfile \(.*\)$~EnableSendfile Off~g' \
  -e 's~AllowOverride \(.*\)$~AllowOverride All~g' \
  /etc/httpd/conf/httpd.conf

# -----------------------------------------------------------------------------
# PHP configuration fixes
# -----------------------------------------------------------------------------

RUN sed -i \
  -e 's~^short_open_tag \(.*\)$~short_open_tag = On~g' \
  -e 's~^max_execution_time \(.*\)$~max_execution_time = 300~g' \
  -e 's~^memory_limit \(.*\)$~memory_limit = 512M~g' \
  -e 's~^post_max_size \(.*\)$~post_max_size = 100M~g' \
  -e 's~^enable_dl \(.*\)$~enable_dl = On~g' \
  -e 's~^upload_max_filesize \(.*\)$~upload_max_filesize = 200M~g' \
  -e "s~^upload_max_filesize = 200M$~upload_max_filesize = 200M\nmax_file_uploads = 200~g" \
	/etc/php.ini

# -----------------------------------------------------------------------------
# MYSQL configuration fixes
# -----------------------------------------------------------------------------

RUN sed -i \
  -e "s~^user=mysql$~user=mysql\nmax_allowed_packet=1073741824~g" \
	/etc/my.cnf

EXPOSE 80
EXPOSE 3306

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
