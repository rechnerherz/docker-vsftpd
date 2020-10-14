# darioseidl/vsftpd

This Docker container implements a vsftpd server, with the following features:

 - Debian Buster base image
 - vsftpd 3.0
 - Virtual users
 - Passive mode
 - Obtain passive mode IP address from AWS EC2 instance

It was originally forked from [fauria/docker-vsftpd](https://github.com/fauria/docker-vsftpd) but has changed a lot since then.

### Build

```
docker build . -t vsftpd:latest
```

### Push

To push it to Docker Hub:

```
docker tag vsftpd:latest $DOCKER_ID_USER/vsftpd:latest
docker push $DOCKER_ID_USER/vsftpd:latest
```
