FROM harningt/base-alpine-s6-overlay:edge

MAINTAINER XtremXpert <xtremxpert@xtremxpert.com>

ENV LANG="fr_CA.UTF-8" \
	LC_ALL="fr_CA.UTF-8" \
	LANGUAGE="fr_CA.UTF-8" \
	TZ="America/Toronto" \
	TERM="xterm"

RUN apk --update add bind

EXPOSE 53

ENTRYPOINT ["/init"]

CMD ["named", "-c", "/etc/bind/named.conf", "-g", "-u", "named"]
