#!/bin/bash
set -x

for ftp_virtual_user in $FTP_VIRTUAL_USERS; do
  read ftp_virtual_username ftp_virtual_password <<< $(echo "$ftp_virtual_user" | sed 's/:/ /g')
  
  mkdir -p "/home/vsftpd/${ftp_virtual_username}"
  chown -R ftp:ftp /home/vsftpd/
  
  echo -e "${ftp_virtual_username}\n${ftp_virtual_password}" >> /etc/vsftpd/virtual_users.txt
done

/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

# Set passive mode parameters:
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html#instancedata-data-retrieval
if [ "$FTP_PASV_ADDRESS" = "*" ]; then
    export FTP_PASV_ADDRESS=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
fi

echo >> /etc/vsftpd/vsftpd.conf
echo "## Passive mode" >> /etc/vsftpd/vsftpd.conf
echo "pasv_address=${FTP_PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=${FTP_PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=${FTP_PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_addr_resolve=${FTP_PASV_ADDR_RESOLVE}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_enable=${FTP_PASV_ENABLE}" >> /etc/vsftpd/vsftpd.conf

echo >> /etc/vsftpd/vsftpd.conf
echo "## File options" >> /etc/vsftpd/vsftpd.conf
echo "file_open_mode=${FTP_FILE_OPEN_MODE}" >> /etc/vsftpd/vsftpd.conf
echo "local_umask=${FTP_LOCAL_UMASK}" >> /etc/vsftpd/vsftpd.conf

# Get log file path
export FTP_LOG_FILE=`grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

# stdout server info:
/usr/bin/ln -sf /dev/stdout "$FTP_LOG_FILE"

# Run vsftpd:
&>/dev/null /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
