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

echo >> /etc/vsftpd/vsftpd.conf
echo "## File options" >> /etc/vsftpd/vsftpd.conf
echo "file_open_mode=${FILE_OPEN_MODE}" >> /etc/vsftpd/vsftpd.conf
echo "local_umask=${LOCAL_UMASK}" >> /etc/vsftpd/vsftpd.conf

# Get log file path
export LOG_FILE=`grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

# stdout server info:
if [ "$LOG_STDOUT" ]; then
    /usr/bin/ln -sf /dev/stdout "$LOG_FILE"
    echo "Hello" >> "$LOG_FILE"
fi

# Run vsftpd:
&>/dev/null /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
