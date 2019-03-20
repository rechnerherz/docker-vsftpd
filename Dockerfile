FROM centos:7

ARG USER_ID=14
ARG GROUP_ID=50

LABEL maintainer="dario@rechnerherz.at"
LABEL description="vsftpd Docker image"
LABEL license="Apache License 2.0"

RUN yum -y update && yum clean all
RUN yum install -y \
	vsftpd \
	db4-utils \
	db4 && yum clean all

RUN usermod -u ${USER_ID} ftp
RUN groupmod -g ${GROUP_ID} ftp

ENV FTP_PASV_ADDRESS *
ENV FTP_PASV_ADDR_RESOLVE NO
ENV FTP_PASV_ENABLE YES
ENV FTP_PASV_MIN_PORT 21100
ENV FTP_PASV_MAX_PORT 21110
ENV FTP_FILE_OPEN_MODE 0666
ENV FTP_LOCAL_UMASK 077

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd.sh
RUN mkdir -p /home/vsftpd/
RUN chown -R ftp:ftp /home/vsftpd/

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21

CMD ["/usr/sbin/run-vsftpd.sh"]
