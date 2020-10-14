# darioseidl/vsftpd

This Docker container implements a vsftpd server, with the following features:

 - Debian Buster base image
 - vsftpd 3.0
 - Virtual users
 - Passive mode
 - Obtain passive mode IP address from AWS EC2 instance

It was originally forked from [fauria/docker-vsftpd](https://github.com/fauria/docker-vsftpd) but has changed a lot since then.

### Security

Use SFTP or another security instead of FTP, if you have a choice. Despite its name vsFTPd cannot be "very secure", because FTP is not a secure protocol at all.

Note: vsftpd must run as root, unless run_as_launching_user is used, which is probably worse from a security point of view than running vsftpd as root:

> run_as_launching_user
    Set to YES if you want vsftpd to run as the user which launched vsftpd. This is useful where root access is not available. MASSIVE WARNING! Do NOT enable this option unless you totally know what you are doing, as naive use of this option can create massive security problems. Specifically, vsftpd does not / cannot use chroot technology to restrict file access when this option is set (even if launched by root). A poor substitute could be to use a deny_file setting such as {/*,*..*}, but the reliability of this cannot compare to chroot, and should not be relied on. If using this option, many restrictions on other options apply. For example, options requiring privilege such as non-anonymous logins, upload ownership changing, connecting from port 20 and listen ports less than 1024 are not expected to work. Other options may be impacted.
    
From the [man page](https://security.appspot.com/vsftpd/vsftpd_conf.html).

### Build

```
docker build . -t vsftpd:<version> -t vsftpd:latest
```

### Push

To push it to Docker Hub:

```
docker tag vsftpd:<version> $DOCKER_ID_USER/vsftpd:<version>
docker tag vsftpd:latest $DOCKER_ID_USER/vsftpd:latest
docker push $DOCKER_ID_USER/vsftpd:<version>
docker push $DOCKER_ID_USER/vsftpd:latest
```
