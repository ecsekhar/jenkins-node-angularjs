# Description
Jenkins build node for Angularjs projects. This project builds a docker image that can be used as build node in Jenkins master. The workflow is:
1. Build the image.
2. Push the image to docker registry.
3. Create the node in Jenkins master and set it to use the image from the registry.
4. Configure build jobs to use the new build node.

# Instructions

## Build

```
./build.sh
```

## Push to Docker registry

Set correct tag in push.sh script and

```
./push.sh
```

# Using the image
You can find the image from dev-docker-registry.org.com/common/jenkins-node-angularjs.
The image configures npm and bower clients to use Tecnotree Nexus as a proxy repo.

You can use the image locally in the following way:
```
# Start the container:
docker run -d --name my-node dev-docker-registry.org.com/common/jenkins-node-angularjs:node-4.7
# Start bash session in the container:
docker exec -it my-test /bin/bash
# Change to jenkins user:
su jenkins
cd
# Clone your repo, do your stuff
git clone https...
...
# Clean-up:
docker stop my-node; docker rm my-node
```
