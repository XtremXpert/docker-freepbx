FROM debian:latest

MAINTAINER XtremXpert <xtremxpert@xtremxpert.com>

ENV DEBIAN_FRONTEND="noninteractive" \
	LANG="fr_CA.UTF-8" \
	LC_ALL="fr_CA.UTF-8" \
	LANGUAGE="fr_CA.UTF-8" \
	TZ="America/Toronto" \
	TERM="xterm"

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/
ADD http://downloads.asterisk.org/pub/telephony/certified-asterisk/certified-asterisk-13.1-current.tar.gz /tmp/
ADD http://mirror.freepbx.org/modules/packages/freepbx/freepbx-13.0-latest.tgz /tmp/

ADD http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-wav-current.tar.gz /tmp/
ADD http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz /tmp/
ADD http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-g722-current.tar.gz /tmp/
ADD http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-g722-current.tar.gz /tmp/
ADD http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-fr-wav-current.tar.gz /tmp/
ADD http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-fr-wav-current.tar.gz /tmp/
ADD http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-fr-g722-current.tar.gz /tmp/
ADD http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-fr-g722-current.tar.gz /tmp/

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
	tar xzf /tmp/certified-asterisk-13.1-current.tar.gz -C /tmp/ && \
	tar xzf /tmp/freepbx-13.0-latest.tgz -C /tmp/

RUN apt-get update && \
	apt-get install --no-install-recommends --no-install-suggests -yqq  \
		apache2 \
		build-essential \
		curl \
		libgtk2.0-dev \
		libjansson-dev \
		libmyodbc \
		libncurses5-dev \
		libsqlite3-dev \
		libxml2-dev \
		locales \
		openssl \
		mariadb-server \
		mariadb-client \
		mc \
		mpg123 \
		nano \
		php5 \
		php5-cli \
		php5-curl \
		php5-gd \
		php5-mysql \
		php-pear \
		pkg-config \
		sox \
		sudo \
		sqlite3 \
		tzdata \
		uuid-dev
		
RUN echo $TZ > /etc/timezone && \ 
	dpkg-reconfigure tzdata && \
	echo 'alias ll="ls -lah --color=auto"' >> /etc/bash.bashrc && \
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	echo "fr_CA.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen fr_CA.UTF-8  && \
	dpkg-reconfigure locales

WORKDIR /tmp/certified-asterisk-13.1-cert2
RUN ./configure  && \
	make menuselect.makeopts && \
	sed -i "s/BUILD_NATIVE//" menuselect.makeopts && \
	make && \
	make install && \
	make config && \
	ldconfig

#RUN mkdir /var/lib/asterisk/sounds/en
WORKDIR /var/lib/asterisk/sounds/en
RUN tar xfz /tmp/asterisk-core-sounds-en-wav-current.tar.gz && \
	tar xfz /tmp/asterisk-extra-sounds-en-wav-current.tar.gz && \
	tar xfz /tmp/asterisk-core-sounds-en-g722-current.tar.gz && \
	tar xfz /tmp/asterisk-extra-sounds-en-g722-current.tar.gz 

RUN mkdir /var/lib/asterisk/sounds/fr
WORKDIR /var/lib/asterisk/sounds/fr

RUN tar xfz /tmp/asterisk-core-sounds-fr-wav-current.tar.gz && \
	tar xfz /tmp/asterisk-extra-sounds-fr-wav-current.tar.gz && \
	tar xfz /tmp/asterisk-core-sounds-fr-g722-current.tar.gz && \
	tar xfz /tmp/asterisk-extra-sounds-fr-g722-current.tar.gz 
	
RUN useradd -m asterisk && \
	chown asterisk. /var/run/asterisk && \
	chown -R asterisk. /etc/asterisk && \
	chown -R asterisk. /var/{lib,log,spool}/asterisk && \
	chown -R asterisk. /usr/lib/asterisk &&
	rm -rf /var/www/html

RUN pear install Console_Getopt && \
	sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php5/apache2/php.ini && \
	cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf_orig && \
	sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/apache2/apache2.conf && \
	sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

RUN cat >> /etc/odbcinst.ini << EOF
[MySQL]
Description = ODBC for MySQL
Driver = /usr/lib/x86_64-linux-gnu/odbc/libmyodbc.so
Setup = /usr/lib/x86_64-linux-gnu/odbc/libodbcmyS.so
FileUsage = 1
EOF

RUN cat >> /etc/odbc.ini << EOF
[MySQL-asteriskcdrdb]
Description=MySQL connection to 'asteriskcdrdb' database
driver=MySQL
server=localhost
database=asteriskcdrdb
Port=3306
Socket=/var/run/mysqld/mysqld.sock
option=3
EOF

WORKDIR /usr/src
RUN tar xfz /tmp/freepbx-13.0-latest.tgz

WORKDIR /usr/src/freepbx
RUN ./start_asterisk start && \
./install -n

EXPOSE 80 5060

ENTRYPOINT ["/init"]
