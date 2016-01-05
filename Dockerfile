FROM harningt/base-alpine-s6-overlay:edge

MAINTAINER XtremXpert <xtremxpert@xtremxpert.com>

ENV LANG="fr_CA.UTF-8" \
	LC_ALL="fr_CA.UTF-8" \
	LANGUAGE="fr_CA.UTF-8" \
	TZ="America/Toronto" \
	TERM="xterm"

RUN echo '@testing http://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories

RUN apk update && \
	apk upgrade && \
	apk --update add \
		bind

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	rm -fr /var/lib/apk/* && \
	rm -rf /var/cache/apk/*

EXPOSE 53 953

ENTRYPOINT ["/init"]

CMD ["named", "-c", "/etc/bind/named.conf", "-g", "-u", "named"]
