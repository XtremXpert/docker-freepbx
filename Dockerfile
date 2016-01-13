FROM alpine:edge

MAINTAINER XtremXpert <xtremxpert@xtremxpert.com>

ENV LANG="fr_CA.UTF-8" \
	LC_ALL="fr_CA.UTF-8" \
	LANGUAGE="fr_CA.UTF-8" \
	TZ="America/Toronto" \
	TERM="xterm"

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
	echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
	apk update && \
	apk upgrade && \
	apk add \
		asterisk \
		ca-certificates \
		mc \
		nano \
		openntpd \
		rsync \
		tar \
		tzdata \
		unzip \
	&& \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	rm -fr /var/lib/apk/* && \
	rm -rf /var/cache/apk/* && \
 	mkdir /etc/services.d/asterisk && \
	echo '#!/usr/bin/execlineb -P'  >> /etc/services.d/asterisk/run && \
	echo 'asterisk'  >> /etc/services.d/asterisk/run

EXPOSE 80 5060

ENTRYPOINT ["/init"]
