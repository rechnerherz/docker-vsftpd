#!/bin/bash
set -x

# Extract users and passwords from env var ("username1:password1 username2:password2")
# Create home and upload directories and write users and passwords to file
touch /etc/vsftpd/virtual_users.txt
for ftp_virtual_user in $FTP_VIRTUAL_USERS; do
  read ftp_virtual_username ftp_virtual_password <<< $(echo "$ftp_virtual_user" | sed 's/:/ /g')

  # Create upload dir
  mkdir -p "/home/vsftpd/${ftp_virtual_username}/upload"
  chown ftp:ftp "/home/vsftpd/${ftp_virtual_username}/upload"

  # Make chroot non-writeable
  chmod a-w "/home/vsftpd/${ftp_virtual_username}"

  echo -e "${ftp_virtual_username}\n${ftp_virtual_password}" >> /etc/vsftpd/virtual_users.txt
done

# Create Berkely DB from list of virtual users
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

# When $FTP_PASV_ADDRESS is set to *, get the IP address from the AWS EC2 instance
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html#instancedata-data-retrieval
if [ "$FTP_PASV_ADDRESS" = "*" ]; then
    export FTP_PASV_ADDRESS=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
fi

# Write passive mode options from env to conf
echo >> /etc/vsftpd/vsftpd.conf
echo "## Passive mode" >> /etc/vsftpd/vsftpd.conf
echo "pasv_address=${FTP_PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=${FTP_PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=${FTP_PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_addr_resolve=${FTP_PASV_ADDR_RESOLVE}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_enable=${FTP_PASV_ENABLE}" >> /etc/vsftpd/vsftpd.conf

# Write file options from env to conf
echo >> /etc/vsftpd/vsftpd.conf
echo "## File options" >> /etc/vsftpd/vsftpd.conf
echo "file_open_mode=${FTP_FILE_OPEN_MODE}" >> /etc/vsftpd/vsftpd.conf
echo "local_umask=${FTP_LOCAL_UMASK}" >> /etc/vsftpd/vsftpd.conf

# Run vsftpd
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
