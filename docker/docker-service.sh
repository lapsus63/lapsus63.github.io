#!/bin/bash

# TODO : improve dynamic options

#######################################
# VARIABLES
#######################################

BUILD_VERSION=v0.01
IMAGE_NAME=$CLI_IMAGE_NAME
HTTPD_PORT=8083

ACTION=$1

#######################################
# fix docker volume mount from git bash, cygwin terms :
#######################################
case $TERM in
 cygwin)
   export MSYS_NO_PATHCONV=1
   ;;
esac


case "$ACTION" in
  #######################################
  # Build Docker Image from Dockerfile  #
  #######################################
  build)
  docker build . -t ${IMAGE_NAME}:${BUILD_VERSION}
  echo Available images:
  docker image ls | grep ${IMAGE_NAME}
  ;;
  
  start)
  echo docker run --rm -d -v \"C:\\Users\\FP17228\\Desktop\\sigma\\public:/usr/local/apache2/htdocs\" -p \"${HTTPD_PORT}:80\" ${IMAGE_NAME}:${BUILD_VERSION}
  ;;
  
  attachc)
  CONTAINER_ID=`docker ps | grep "${IMAGE_NAME}:${BUILD_VERSION}" | awk '{print $1}'`
  docker exec -it $CONTAINER_ID bash
  ;;
  
  attachi)
  echo docker run --rm -it --entrypoint \"bash\" -v \"C:\\Path\\To\\Public:/usr/local/apache2/htdocs\" -p \"${HTTPD_PORT}:80\" ${IMAGE_NAME}:${BUILD_VERSION}
  ;;
  
  logs)
  CONTAINER_ID=`docker ps | grep "${IMAGE_NAME}:${BUILD_VERSION}" | awk '{print $1}'`
  docker logs -n 30 -f $CONTAINER_ID
  ;;
  
  stop)
  CONTAINER_ID=`docker ps | grep "${IMAGE_NAME}:${BUILD_VERSION}" | awk '{print $1}'`
  docker stop $CONTAINER_ID
  ;;
  
  status)
  docker ps -a | grep "${IMAGE_NAME}:${BUILD_VERSION}"
  ;;
  
  *)
    echo "Usage: $0 {build|start|attachc|attachi|logs|stop|status}"
    exit 1
esac
