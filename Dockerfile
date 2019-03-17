FROM debian:stretch-slim

ENV VERSION=5.10.19-11646-1

ENV BDEPS apt-transport-https gnupg
RUN mkdir /usr/share/man/man1 && \
  useradd --uid 1000 -s /bin/false -d /var/lib/unifi unifi && \
  apt-get -qy update && apt-get -qy install $BDEPS && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50 && \
  echo "deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti" > \
    /etc/apt/sources.list.d/100-ubnt-unifi.list && \
  apt-get -qy update && \
  apt-get -qy install unifi=$VERSION && \
  apt-get -qy remove $BDEPS && \
  apt-get -qy autoremove && \
  apt-get -qy clean && \
  rm -rf /var/lib/apt/lists/*

# Somehow setting -Dunifi.datadir=/data/data alone doesn't work.
RUN install -d -o unifi /usr/lib/unifi/logs /data/data && \
  ln -s /data/data /usr/lib/unifi/data && \
  ln -s /dev/stdout /usr/lib/unifi/logs/server.log && \
  ln -s /dev/stdout /usr/lib/unifi/logs/mongod.log

ADD run-unifi /usr/bin/
USER unifi
VOLUME [ "/data" ]
WORKDIR /usr/lib/unifi
ENTRYPOINT [ "/usr/bin/run-unifi" ]
CMD [ "com.ubnt.ace.Launcher", "start" ]
EXPOSE 8443
