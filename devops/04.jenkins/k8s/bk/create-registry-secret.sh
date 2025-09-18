#!/bin/bash

DOCKER_REGISTRY="amdp-registry.skala-ai.com"
DOCKER_REGISTRY_USER="robot\$skala25a"
DOCKER_REGISTRY_PASSWORD="1qB9cyusbNComZPHAdjNIFWinf52xaBJ"
DOCKER_CACHE="--no-cache"

kubectl create secret docker-registry regcred \
  --docker-server=${DOCKER_REGISTRY} \
  --docker-username=${DOCKER_REGISTRY_USER} \
  --docker-password=${DOCKER_REGISTRY_PASSWORD} \
  --docker-email=yongwooyi@skala-ai.com \
  -n jenkins
