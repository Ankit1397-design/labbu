ADD file:4f526aa99067d82b341f7ca538f7826b7c23a628f1b615eea2883a2d434c1b90 in /
CMD ["/bin/sh"]
ARG GF_UID=472
ARG GF_GID=0
ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin GF_PATHS_CONFIG=/etc/grafana/grafana.ini GF_PATHS_DATA=/var/lib/grafana GF_PATHS_HOME=/usr/share/grafana GF_PATHS_LOGS=/var/log/grafana GF_PATHS_PLUGINS=/var/lib/grafana/plugins GF_PATHS_PROVISIONING=/etc/grafana/provisioning
WORKDIR /usr/share/grafana
RUN |2 GF_UID=472 GF_GID=0 /bin/sh -c apk add --no-cache ca-certificates bash tzdata &&     apk add --no-cache openssl musl-utils # buildkit
RUN |2 GF_UID=472 GF_GID=0 /bin/sh -c if [ `arch` = "x86_64" ]; then       apk add --no-cache libaio libnsl &&       ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1 &&       wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk         -O /tmp/glibc-2.30-r0.apk &&       wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-bin-2.30-r0.apk         -O /tmp/glibc-bin-2.30-r0.apk &&       apk add --allow-untrusted /tmp/glibc-2.30-r0.apk /tmp/glibc-bin-2.30-r0.apk &&       rm -f /tmp/glibc-2.30-r0.apk &&       rm -f /tmp/glibc-bin-2.30-r0.apk &&       rm -f /lib/ld-linux-x86-64.so.2 &&       rm -f /etc/ld.so.cache;     fi # buildkit
COPY /tmp/grafana /usr/share/grafana # buildkit
RUN |2 GF_UID=472 GF_GID=0 /bin/sh -c if [ ! $(getent group "$GF_GID") ]; then       addgroup -S -g $GF_GID grafana;     fi # buildkit
RUN |2 GF_UID=472 GF_GID=0 /bin/sh -c export GF_GID_NAME=$(getent group $GF_GID | cut -d':' -f1) &&     mkdir -p "$GF_PATHS_HOME/.aws" &&     adduser -S -u $GF_UID -G "$GF_GID_NAME" grafana &&     mkdir -p "$GF_PATHS_PROVISIONING/datasources"              "$GF_PATHS_PROVISIONING/dashboards"              "$GF_PATHS_PROVISIONING/notifiers"              "$GF_PATHS_PROVISIONING/plugins"              "$GF_PATHS_LOGS"              "$GF_PATHS_PLUGINS"              "$GF_PATHS_DATA" &&     cp "$GF_PATHS_HOME/conf/sample.ini" "$GF_PATHS_CONFIG" &&     cp "$GF_PATHS_HOME/conf/ldap.toml" /etc/grafana/ldap.toml &&     chown -R "grafana:$GF_GID_NAME" "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING" &&     chmod -R 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING" # buildkit
EXPOSE map[3000/tcp:{}]
COPY ./run.sh /run.sh # buildkit
USER 472
ENTRYPOINT ["/run.sh"]
