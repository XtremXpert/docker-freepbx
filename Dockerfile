FROM debian:latest

MAINTAINER XtremXpert <xtremxpert@xtremxpert.com>

ENV DEBIAN_FRONTEND="noninteractive" \
	LANG="fr_CA.UTF-8" \
	LC_ALL="fr_CA.UTF-8" \
	LANGUAGE="fr_CA.UTF-8" \
	TZ="America/Toronto" \
	TERM="xterm"

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/
ADD http://mirror.freepbx.org/modules/packages/freepbx/freepbx-13.0-latest.tgz /usr/src/

RUN tar xvzf /tmp/s6-overlay-amd64.tar.gz -C /
RUN tar xvzf /usr/src/certified-asterisk-13.1-current.tar.gz -C /usr/src/
RUN tar xvzf /usr/src/freepbx-13.0-latest.tgz -C /usr/src/

RUN apt-get update && \
	apt-get install --no-install-recommends --no-install-suggests -yqq  \
		apache2 \
		binutils-dev \
		build-essential \
		curl \
		cron \
		doxygen \
		freetds-dev \
		git \
		libasound2-dev \
		libc-client-dev \
		libcorosync-dev \
		libcurl4-openssl-dev \
		libedit-dev \
		libgtk2.0-dev \
		libgmime-2.6-dev \
		libgsm1-dev \
		libh323plus-dev \
		libical-dev \
		libiksemel-dev \
		libjack-dev \
		libjansson-dev \
		libldap-dev \
		liblua5.1-0-dev \
		libmyodbc \
		libmysqlclient15-dev \
		libmysqlclient-dev \
		libncurses-dev \
		libncurses5-dev \
		libneon27-dev \
		libnewt-dev \
		libogg-dev \
		libpopt-dev \
		libpq-dev \
		libfreeradius-client-dev \
		libresample-dev \
		libsnmp-dev \
		libspandsp-dev \
		libspeex-dev \
		libspeexdsp-dev \
		libsqlite0-dev \
		libsqlite3-dev \
		libsrtp-dev \
		libssl-dev \
		libusb-dev \
		libvorbis-dev \
		libvpb-dev \
		libxml2-dev \
		libxslt1-dev \
		libz-dev \
		locales \
		lua5.1 \
		openssl \
		mariadb-server \
		mariadb-client \
		mc \
		mpg123 \
		nano \
		portaudio19-dev \
		php5 \
		php5-cli \
		php5-curl \
		php5-gd \
		php5-mysql \
		php-pear \
		pkg-config \
		sox \
		subversion \
		sudo \
		sqlite3 \
		tzdata \
		unixodbc-dev \
		uuid \
		uuid-dev

#Copie des fichiers de configuration des services S6 et de l'ODBC
COPY etc/ /etc/

#Localisation du serveur en fonction des variable d'environnement
RUN echo $TZ > /etc/timezone && \
	dpkg-reconfigure tzdata && \
	echo 'alias ll="ls -lah --color=auto"' >> /etc/bash.bashrc && \
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	echo "fr_CA.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen fr_CA.UTF-8  && \
	dpkg-reconfigure locales

RUN pear install Console_Getopt && \
	sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php5/apache2/php.ini && \
	cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf_orig && \
	sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/apache2/apache2.conf && \
	sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

#Compillation et installation de PJSIP
RUN cd /usr/src && \
	svn co --non-interactive --trust-server-cert http://svn.pjsip.org/repos/pjproject/trunk/ pjproject-trunk && \
	cd pjproject-trunk && \
	./configure \
		--libdir=/usr/lib64 \
		--prefix=/usr \
		--enable-shared \
		--disable-sound \
		--disable-resample \
		--disable-video \
		--disable-opencore-amr \
		CFLAGS='-O2 \
		-DNDEBUG' \
	&& \
	make dep && \
	make && \
	make install && \
	ldconfig

# Compillation et installation d'Asterisk
ADD http://downloads.asterisk.org/pub/telephony/certified-asterisk/certified-asterisk-13.1-current.tar.gz /usr/src/
RUN cd /usr/src/ &&
	tar xvzf /usr/src/certified-asterisk-13.1-current.tar.gz && \
	cd certified-asterisk-13.1-cert2 && \
	menuselect.makeopts  && \
	sed -i "s/BUILD_NATIVE//" menuselect.makeopts && \
	sed -i "s/MENUSELECT_CORE_SOUNDS=CORE-SOUNDS-EN-GSM/MENUSELECT_CORE_SOUNDS=CORE-SOUNDS-EN-GSM CORE-SOUNDS-FR-GSM/" menuselect.makeopts && \
	sed -i "s/MENUSELECT_EXTRA_SOUNDS=/MENUSELECT_EXTRA_SOUNDS=EXTRA-SOUNDS-EN-GSM EXTRA-SOUNDS-FR-GSM/" menuselect.makeopts && \
	./configure && \
	make && \
	make install && \ 
	make config && \
	mkdir -p /etc/asterisk && \
	useradd -m asterisk && \
	chown asterisk. /var/run/asterisk && \
	chown -R asterisk. /etc/asterisk && \
	chown -R asterisk. /var/{lib,log,spool}/asterisk && \
	chown -R asterisk. /usr/lib/asterisk && \
	rm -rf /var/www/html

RUN cd /usr/src/freepbx &&
	./start_asterisk start && \
	./install -n

EXPOSE 80 5060

ENTRYPOINT ["/init"]
