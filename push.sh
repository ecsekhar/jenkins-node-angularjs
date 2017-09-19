#!/bin/bash
IMAGE_NAME="dev-docker-registry.org.com/common/jenkins-node-angularjs"
IMAGE_ID="$(docker images -q ${IMAGE_NAME}:latest)"
IMAGE_TAG="nodejs-4.7"
docker tag ${IMAGE_ID} ${IMAGE_NAME}:${IMAGE_TAG}
docker push ${IMAGE_NAME}:${IMAGE_TAG}
