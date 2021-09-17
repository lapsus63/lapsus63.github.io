### Build its own image

See How-To https://docs.docker.com/engine/reference/commandline/push/

```bash
# Commit container as image
docker container commit a1a3 image-name:1.0
# Tag image 
docker image tag image-name:1.0 docker/image-name:1.0
# Push to docker repository
docker image push docker/image-name:1.0

# Pull to check:
docker pull docker/image-name:1.0
```

# Tips

### Execute a bash shell in a stopped container

```bash
docker run -it --entrypoint /bin/bash mkoperski/robotframework:latest
docker run -it --entrypoint /bin/bash robotframework-docker_server
```
Start a shell from a fresh linux distro :
```bash
docker run -it --entrypoint /bin/bash linux:1.4-alpine3.10
```
