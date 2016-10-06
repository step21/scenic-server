FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV PHPLDAPADMIN_VERSION 1.2.3

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy apache2 bsdtar ca-certificates curl libapache2-mod-php5 patch php5-curl php5-ldap ssl-cert && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /var/www/html/* && \
    rm -f /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/private/ssl-cert-snakeoil.key

RUN find /etc/apache2 -name *.conf -exec sed -i 's|CustomLog .*access.log|CustomLog /proc/self/fd/1|;s|ErrorLog .*error.log|ErrorLog /proc/self/fd/2|;' '{}' \;

RUN mkdir -p /opt/phpldapadmin && \
    curl -Ls "http://downloads.sourceforge.net/project/phpldapadmin/phpldapadmin-php5/${PHPLDAPADMIN_VERSION}/phpldapadmin-${PHPLDAPADMIN_VERSION}.tgz" | bsdtar -xf- --strip-components 1 -C /opt/phpldapadmin && \
    chown -R root:root /opt/phpldapadmin && \
    chmod -R u=rwX,g=rX,o=rX /opt/phpldapadmin

COPY config.php /opt/phpldapadmin/config/config.php
COPY ldap.conf /etc/ldap/ldap.conf
COPY php5.5.patch /opt/phpldapadmin/

RUN patch -p1 -d /opt/phpldapadmin < /opt/phpldapadmin/php5.5.patch && \
    sed -i 's|password_hash|password_hash_custom|g;' /opt/phpldapadmin/lib/TemplateRender.php
RUN rm -rf /var/www/html && \
    ln -sf /opt/phpldapadmin/htdocs /var/www/html
RUN mv /opt/phpldapadmin/config /opt/phpldapadmin/config.default

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80/tcp 443/tcp
VOLUME [ "/opt/phpldapadmin/config" ]
WORKDIR /opt/phpldapadmin

ENTRYPOINT [ "/docker-entrypoint.sh" ]
#CMD [ "apache2" ]
