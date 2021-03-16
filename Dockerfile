
# very good, with maven, multi arch, possibly outdated, @TODO: find something as good but updated
FROM maven:3-adoptopenjdk-11 as buildImg

RUN java -version
RUN mvn --version

# First, cache the maven dependencies. They're very unlikely to change, all that's needed is pom.xml
# This assumes github will serve etags etc so docker caching will work. un tested
ADD https://raw.githubusercontent.com/librespot-org/librespot-java/dev/pom.xml /mvn/src/
ADD https://raw.githubusercontent.com/librespot-org/librespot-java/dev/lib/pom.xml /mvn/src/lib/
ADD https://raw.githubusercontent.com/librespot-org/librespot-java/dev/player/pom.xml /mvn/src/player/
ADD https://raw.githubusercontent.com/librespot-org/librespot-java/dev/api/pom.xml /mvn/src/api/



WORKDIR /mvn/src
RUN set -ex \
 && mvn --batch-mode --show-version \
        --define 'maven.repo.local=/mvn/repo' \
        dependency:list-repositories \
        dependency:go-offline \
        --define 'altDeploymentRepository=local::default::file:///mvn/lib' || true


# Finally add all the source tree and fire off the complete build.
RUN set -ex && cd /mvn && git clone --single-branch --branch dev https://github.com/librespot-org/librespot-java.git fullsrc
RUN set -ex && cd /mvn && mv -v src old.src && mv -v fullsrc src
RUN set -ex && mvn --batch-mode --show-version --define 'maven.repo.local=/mvn/repo' --define 'altDeploymentRepository=local::default::file:///mvn/lib' package

### NO CACHING ###  # Add all the source tree and fire off the complete build.
### NO CACHING ###  WORKDIR /mvn
### NO CACHING ###  RUN set -ex && cd /mvn && git clone --single-branch --branch dev https://github.com/librespot-org/librespot-java.git fullsrc
### NO CACHING ###  RUN set -ex && cd /mvn && mv -v fullsrc src
### NO CACHING ###  RUN set -ex && cd /mvn/src && mvn --batch-mode --show-version package

# Debug
RUN ls -la /mvn/src/player/target


# adoptopenjdk:11-jre-hotspot is already multiarch. it is a bit heavy, but fits our purposes.
# if an alpine/slim/whatever comes along it would be good.
FROM adoptopenjdk:11-jre-hotspot
COPY --from=buildimg /mvn/src/player/target/librespot-player-*.jar /app/librespot-player.jar
WORKDIR /app

# Java version...
RUN java -version

# Debug
# RUN java -jar /app/librespot-player.jar

CMD ["java", "-jar", "/app/librespot-player.jar"]
