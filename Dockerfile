FROM debian:latest

MAINTAINER XtremXpert <xtremxpert@xtremxpert.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y \
    	bind9 \
    	supervisor \
    	dns-utils \
    	rng-tools \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 53

CMD ["named", "-c", "/etc/bind/named.conf", "-g", "-u", "named"]
