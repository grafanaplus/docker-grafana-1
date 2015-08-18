FROM debian:jessie

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
ENV GRAFANA_VERSION 2.1.1
ENV GRAFANA_MD5SUM 60461f5bf9b44934da6a833fa2af9c91
ENV GRAFANA_PLUGINS_VERSION e13a138f8e52649f774189254f88f0e0ccdf3ddd
ENV GRAFANA_PLUGINS_MD5SUM 09564ef28392d182426b0f4f2b1729b9

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

# Log file
RUN ln -sf /dev/null /var/log/grafana/grafana.log
RUN ln -sf /dev/null /var/log/grafana/xorm.log

VOLUME ["/var/lib/grafana"]
#VOLUME ["/etc/grafana"]

EXPOSE 3000

WORKDIR /usr/share/grafana

CMD ["/usr/sbin/grafana-server", "--config=/etc/grafana/grafana.ini", "cfg:default.paths.data=/var/lib/grafana", "cfg:default.paths.logs=/var/log/grafana"]
