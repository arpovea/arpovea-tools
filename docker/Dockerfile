FROM debian:bookworm-slim

# Configurar frontend no interactivo para automatizar la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Instalación de herramientas y utilidades
RUN apt-get update && apt-get install -y \
    busybox \
    curl \
    git \
    gnupg \
    htop \
    iperf \
    iputils-ping \
    iputils-tracepath \
    jq \
    mariadb-client \
    net-tools \
    nfs-common \
    nmap \
    openssl \
    postgresql-client \
    redis-tools \
    rsync \
    strace \
    sudo \
    tcpdump \
    tree \
    unzip \
    vim \
    wget \
    zip && \
    # MONGODB
    wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add - && \
    echo "deb http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update && apt-get install -y mongodb-database-tools mongodb-mongosh && \
    # Limpieza de cache
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instalación de RCLONE
RUN curl -sO https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip rclone-current-linux-amd64.zip && \
    mv rclone-*-linux-amd64/rclone /usr/local/bin/ && \
    rm -r rclone-* && \
    chmod +x /usr/local/bin/rclone

# Copiar scripts personalizados y ajustando permisos para compatibilidad con entornos Openshift
COPY scripts/*.sh /bin/
RUN chown -R 1001:0 /bin/*.sh && \
    chmod +x /bin/*.sh

# Cambiar a un usuario no root
USER 1001

# Configurar entrypoint
ENTRYPOINT ["/bin/entrypoint.sh"]
