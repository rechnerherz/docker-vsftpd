#!/bin/bash
set -x

# Do not log to STDOUT by default:
if [ "$LOG_STDOUT" = "**Boolean**" ]; then
    export LOG_STDOUT=''
else
    export LOG_STDOUT='Yes.'
fi

for ftp_virtual_user in $FTP_VIRTUAL_USERS; do
  read ftp_virtual_username ftp_virtual_password <<< $(echo "$ftp_virtual_user" | sed 's/:/ /g')
  
  mkdir -p "/home/vsftpd/${ftp_virtual_username}"
  chown -R ftp:ftp /home/vsftpd/
  
  echo -e "${ftp_virtual_username}\n${ftp_virtual_password}" >> /etc/vsftpd/virtual_users.txt
done

/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

# Set passive mode parameters:
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html#instancedata-data-retrieval
if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
    export PASV_ADDRESS=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
fi

echo >> /etc/vsftpd/vsftpd.conf
echo "## Passive mode" >> /etc/vsftpd/vsftpd.conf
echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=${PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=${PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_addr_resolve=${PASV_ADDR_RESOLVE}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_enable=${PASV_ENABLE}" >> /etc/vsftpd/vsftpd.conf

echo >> /etc/vsftpd/vsftpd.conf
echo "## File options" >> /etc/vsftpd/vsftpd.conf
echo "file_open_mode=${FILE_OPEN_MODE}" >> /etc/vsftpd/vsftpd.conf
echo "local_umask=${LOCAL_UMASK}" >> /etc/vsftpd/vsftpd.conf

# Get log file path
export LOG_FILE=`grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

# stdout server info:
if [ "$LOG_STDOUT" ]; then
    /usr/bin/ln -sf /dev/stdout "$LOG_FILE"
fi

# Run vsftpd:
&>/dev/null /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
