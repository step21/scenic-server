FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy ldap-utils ldapvi schema2ldif slapd slapd-smbk5pwd vim-tiny && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /etc/ldap/slapd.d /var/lib/ldap

COPY ldap.conf /etc/ldap/ldap.conf
COPY ldaprc /root/.ldaprc
COPY ldapvirc /root/.ldapvirc
COPY schema/ /etc/ldap/schema/
COPY slapd.init.ldif /usr/share/slapd/slapd.init.ldif

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 389/tcp 636/tcp
VOLUME [ "/etc/ldap/slapd.d", "/var/lib/ldap" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
#CMD [ "slapd" ]
