# darioseidl/vsftpd

This Docker container implements a vsftpd server, with the following features:

 * Centos 7 base image.
 * vsftpd 3.0
 * Virtual users
 * Logging to a file or STDOUT.

It was forked from https://github.com/fauria/docker-vsftpd to support creating virtual users from an env var.
