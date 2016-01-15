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

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / 
RUN tar xzf /tmp/certified-asterisk-13.1-current.tar.gz -C /tmp/ 
RUN tar xzf /tmp/freepbx-13.0-latest.tgz -C /tmp/

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
RUN echo $TZ > /etc/timezone 
RUN dpkg-reconfigure tzdata 
RUN echo 'alias ll="ls -lah --color=auto"' >> /etc/bash.bashrc  
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen 
RUN echo "fr_CA.UTF-8 UTF-8" >> /etc/locale.gen 
RUN locale-gen fr_CA.UTF-8
RUN dpkg-reconfigure locales

RUN cd /tmp/certified-asterisk-13.1*
RUN ./configure;
RUN make menuselect.makeopts
RUN sed -i "s/BUILD_NATIVE//" menuselect.makeopts
RUN make; make install; make samples; make config

EXPOSE 80 5060

ENTRYPOINT ["/init"]
