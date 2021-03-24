FROM ubuntu:latest

RUN apt-get -y update
RUN apt-get -y install openjdk-11-jre pulseaudio

ADD https://github.com/librespot-org/librespot-java/releases/download/v1.5.5/librespot-player-1.5.5.jar /app/librespot-player.jar
ADD config.toml /app/config.toml

WORKDIR /app

# Java version...
RUN java -version

CMD ["java", "-jar", "/app/librespot-player.jar"]
