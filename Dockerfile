FROM harningt/base-alpine-s6-overlay:edge

MAINTAINER XtremXpert <xtremxpert@xtremxpert.com>

RUN apk --update add bind

EXPOSE 53

#ENTRYPOINT ["/init"]

#CMD ["named", "-c", "/etc/bind/named.conf", "-g", "-u", "named"]
