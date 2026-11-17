FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

COPY codesys-4_1.0.0.0_amd64.deb /tmp/codesys-4.deb

# install dependencies and the CODESYS 4 server package, then clean up
RUN apt-get update \
    && apt-get install -y --no-install-recommends /tmp/codesys-4.deb \
    && rm -rf /tmp/codesys-4.deb /var/lib/apt/lists/*

# create group codesys-4 and the system user that runs the server
RUN (getent group codesys-4 || groupadd codesys-4) \
    && useradd --system --create-home c4-server

# create user for logging in to the application (member of codesys-4) and
# set the password at build time: --build-arg C4_PASSWORD=...
ARG C4_USER=christian
ARG C4_PASSWORD=changeme
RUN useradd --create-home --shell /bin/bash --groups codesys-4 ${C4_USER} \
    && echo "${C4_USER}:${C4_PASSWORD}" | chpasswd

# create a volume for the server data and set the owner to c4-server
RUN mkdir -p /var/opt/codesys-4 \
    && chown -R c4-server:codesys-4 /var/opt/codesys-4
VOLUME /var/opt/codesys-4

USER c4-server
WORKDIR /opt/codesys-4
ENV ASPNETCORE_ENVIRONMENT=Production \
    DOTNET_PRINT_TELEMETRY_MESSAGE=false

# expose the port and start the server
EXPOSE 8080
CMD ["/opt/codesys-4/c4-server", "--port", "8080"]
