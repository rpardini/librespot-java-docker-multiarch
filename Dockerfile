FROM ubuntu:latest

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends openjdk-11-jre pulseaudio && \
    apt-get clean

ADD https://github.com/librespot-org/librespot-java/releases/download/v1.5.5/librespot-player-1.5.5.jar /app/librespot-player.jar
ADD config.toml /config/config.toml

WORKDIR /app

# Java version...
RUN java -version

# Allow everyone to read the jar and config, and to write the config (app writes to it during normal operations)
RUN chmod -R ugo+r /app /config && chmod -R ugo+w /config/config.toml

CMD ["java", "-jar", "/app/librespot-player.jar", "--conf-file=/config/config.toml"]
