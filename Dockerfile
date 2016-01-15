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

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
	tar xzf /tmp/scertified-asterisk/certified-asterisk-13.1-current.tar.gz -C /tmp/ && \
	apt-get update && \
	apt-get install --no-install-recommends --no-install-suggests -yqq  \
		build-essential \
		curl \
		libgtk2.0-dev \
		libjansson-dev \ 
		libncurses5-dev \
		libsqlite3-dev \ 
		libxml2-dev \
		openssl \
		mc \
		nano \
		pkg-config \
		sqlite3 \
		tzdata \
		uuid-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /tmp/certified-asterisk-13.1-cert2

RUN ./configure;
RUN make menuselect.makeopts
RUN sed -i "s/BUILD_NATIVE//" menuselect.makeopts
RUN make; make install; make samples; make config

EXPOSE 80 5060

ENTRYPOINT ["/init"]
