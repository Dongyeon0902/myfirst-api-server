#!/bin/bash

NAME=sk199
SERVICE_NAME="custom-jenkins"

kubectl create configmap ${NAME}-${SERVICE_NAME}-config \
  --from-file=jenkins.yaml=jenkins.yaml \
  --namespace=skala-practice
