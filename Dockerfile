FROM ubuntu:latest

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends openjdk-11-jre pulseaudio && \
    apt-get clean

ADD https://github.com/librespot-org/librespot-java/releases/download/v1.5.5/librespot-player-1.5.5.jar /app/librespot-player.jar
ADD config.toml /config/config.toml

WORKDIR /app

# Java version...
RUN java -version

# Add user to system
RUN useradd -ms /bin/bash app
RUN id app
RUN chown -R app:app /app /config

# Use app user as default, avoid running as root
USER app

CMD ["java", "-jar", "/app/librespot-player.jar", "--conf-file=/config/config.toml"]
