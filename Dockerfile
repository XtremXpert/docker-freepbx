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
ADD http://www.pjsip.org/release/2.4.5/pjproject-2.4.5.tar.bz2 /tmp/

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /
RUN tar xzf /tmp/certified-asterisk-13.1-current.tar.gz -C /usr/src/
#RUN tar xvjf /tmp/pjproject-2.4.5.tar.bz2 -C /usr/src/
RUN tar xzf /tmp/freepbx-13.0-latest.tgz -C /usr/src/

RUN apt-get update && \
	apt-get install --no-install-recommends --no-install-suggests -yqq  \
		apache2 \
		binutils-dev \
		build-essential \
		curl \
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

COPY etc/ /etc/

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

EXPOSE 80 5060

ENTRYPOINT ["/init"]
