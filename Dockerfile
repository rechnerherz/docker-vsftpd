# Debian Buster slim image
# https://hub.docker.com/_/debian
FROM debian:buster-slim

LABEL maintainer="dario@rechnerherz.at"
LABEL description="vsftpd Docker image"
LABEL license="Apache License 2.0"

# Install vsftpd, db-util (for db_load command) and curl
RUN set -x\
 && apt-get update\
 && apt-get install --no-install-recommends -y vsftpd db-util curl\
 && rm -rf /var/lib/apt/lists/*

# Copy config files
COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/local/bin/

RUN set -x\
 && chmod +x /usr/local/bin/run-vsftpd.sh\
 && mkdir -p /home/vsftpd/\
 && mkdir -p /var/log/vsftpd\
 && ln -sf /dev/stdout /var/log/vsftpd/vsftpd.log

# Set default env values
ENV FTP_PASV_ADDRESS *
ENV FTP_PASV_ADDR_RESOLVE NO
ENV FTP_PASV_ENABLE YES
ENV FTP_PASV_MIN_PORT 21100
ENV FTP_PASV_MAX_PORT 21109
ENV FTP_FILE_OPEN_MODE 0666
ENV FTP_LOCAL_UMASK 077

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21 21100 21101 21102 21103 21104 21105 21106 21107 21108 21109

CMD ["/usr/local/bin/run-vsftpd.sh"]
