FROM debian:latest

MAINTAINER XtremXpert <xtremxpert@xtremxpert.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y \
    	bind9 \
    	supervisor \
    	dnsutils \
    	rng-tools \
    && \
    apt-get clean && \
   	echo "HRNGDEVICE=/dev/urandom" >> /etc/default/rng-tools && \
   	echo "RNGDOPTIONS=\"--fill-watermark=80% --timeout=20\"" >> /etc/default/rng-tools && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 53

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
