FROM debian:jessie

# Grafana user and group
RUN groupadd -g 999 grafana && useradd -d /var/lib/postgresql/9.3 -u 999 -g 999 grafana


# Gosu
RUN    gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && apt-get update \
    && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/* \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && apt-get purge -y --auto-remove curl


# Grafana version
ENV GRAFANA_VERSION 2.1.3
ENV GRAFANA_MD5SUM e3a7c2dad4889d2a48b911313e1da8a8
ENV GRAFANA_PLUGINS_VERSION 47351473822ec4885d4fb0a57d5c7453718e4045
ENV GRAFANA_PLUGINS_MD5SUM fc00ef384deac2acb61bcc95f4aa40e8

# Grafana package
RUN    apt-get update \
    && apt-get install -y curl libfontconfig \
    && curl -SL -o /tmp/grafana.deb https://grafanarel.s3.amazonaws.com/builds/grafana_${GRAFANA_VERSION}_amd64.deb \
    && curl -SL -o /tmp/plugins.tgz https://github.com/grafana/grafana-plugins/archive/${GRAFANA_PLUGINS_VERSION}.tar.gz \
    && echo "${GRAFANA_MD5SUM}  /tmp/grafana.deb" | md5sum -c \
    && echo "${GRAFANA_PLUGINS_MD5SUM}  /tmp/plugins.tgz" | md5sum -c \
    && dpkg -i /tmp/grafana.deb \
    && cd /usr/share/grafana/public/app/plugins/datasource \
    && tar --strip-components 2 -x -z -f /tmp/plugins.tgz \
    && rm -rf /tmp/grafana.deb \
    && rm -rf /tmp/plugins.tgz \
    && apt-get -y --purge --auto-remove remove curl \
    && rm -rf /var/lib/apt/lists/*


# Add files
ADD entrypoint.sh /docker/entrypoint.sh
RUN chmod 0755 /docker/entrypoint.sh


# Log file
RUN ln -sf /dev/null /var/log/grafana/grafana.log
RUN ln -sf /dev/null /var/log/grafana/xorm.log


VOLUME ["/var/lib/grafana"]

EXPOSE 3000

WORKDIR /usr/share/grafana

ENTRYPOINT ["/docker/entrypoint.sh"]
CMD ["grafana-server", "--config=/etc/grafana/grafana.ini", "cfg:default.paths.data=/var/lib/grafana", "cfg:default.paths.logs=/var/log/grafana"]
