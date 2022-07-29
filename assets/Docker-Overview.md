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

### Execute a bash shell in a stopped container

```bash
docker run -it --entrypoint /bin/bash mkoperski/robotframework:latest
docker run -it --entrypoint /bin/bash robotframework-docker_server
```
Start a shell from a fresh linux distro :
```bash
docker run -it --entrypoint /bin/bash linux:1.4-alpine3.10
```

### Force container to keep running on a TTY

In `docker-compose.yml` :

```yaml
entrypoint: /bin/bash
stdin_open: true # docker run -i
tty: true        # docker run -t
```

### Statistics

Show each layer size :

```bash
docker system df
```

Show container CPU and RAM consumption in live :

```bash
docker stats
```

Show image layer sizes :

```bash
docker history <image_name>
```

### Docker for Windows : move ext4 partition

source: https://stackoverflow.com/questions/62441307/how-can-i-change-the-location-of-docker-images-when-using-docker-desktop-on-wsl2

Stop Docker Service

```bash
wsl  --shutdown
# check : 
wsl --list -v
```
Export docker-desktop-data into a file

```bash
wsl --export docker-desktop-data "D:\Docker\wsl\data\docker-desktop-data.tar"
wsl --unregister docker-desktop-data
wsl --import docker-desktop-data "D:\Docker\wsl\data" "D:\Docker\wsl\data\docker-desktop-data.tar" --version 2
```

### Docker for Windows : reduce size of ext4 partition

Stop Docker service

Run Powershell in admin mode:

```powershell
Optimize-VHD -Path c:\path\to\data.vhdx -Mode Full
```
