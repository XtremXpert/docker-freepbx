FROM alpine:edge

MAINTAINER XtremXpert <xtremxpert@xtremxpert.com>

RUN apk --update add bind rng-tools

EXPOSE 53

CMD ["named", "-c", "/etc/bind/named.conf", "-g", "-u", "named"]
