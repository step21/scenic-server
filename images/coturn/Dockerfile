FROM debian:sid
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy coturn curl gosu ldap-utils && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /etc/coturn.default && \
    ln -fs /etc/coturn/turnserver.conf /etc/turnserver.conf
COPY turnserver.conf /etc/coturn.default/

COPY ldap2turn.sh /
RUN chmod +x /ldap2turn.sh

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 3478/tcp 3478/udp
VOLUME [ "/etc/coturn", "/var/lib/turn" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["turnserver"]
