FROM alpine:edge

MAINTAINER XtremXpert <xtremxpert@xtremxpert.com>

ENV LANG="fr_CA.UTF-8" \
	LC_ALL="fr_CA.UTF-8" \
	LANGUAGE="fr_CA.UTF-8" \
	TZ="America/Toronto" \
	TERM="xterm"

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && \
	apk update && \
	apk add \
		bind \
		bind-tools \
		ca-certificates \
		mc \
		nano \
		openntpd \
		rsync \
		tar \
		tzdata \
		unzip \
	&& \
	mkdir /etc/service.d/named && \
	echo "#!/usr/bin/execlineb -P"  >> /etc/service.d/named/run && \
	echo "named -c /etc/bind/named.conf -g -4 -u named"  >> /etc/service.d/named/run && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	rm -fr /var/lib/apk/* && \
	rm -rf /var/cache/apk/*

EXPOSE 53 953

ENTRYPOINT ["/init"]
