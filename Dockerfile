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
		build-essential \
		curl \
		libgtk2.0-dev \
		libjansson-dev \ 
		libncurses5-dev \
		libsqlite3-dev \ 
		libxml2-dev \
		locales \
		openssl \
		mc \
		nano \
		pkg-config \
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

EXPOSE 80 5060

ENTRYPOINT ["/init"]
