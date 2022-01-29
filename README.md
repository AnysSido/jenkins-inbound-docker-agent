# Jenkins Inbound Agent with Docker CLI

This docker image is an extension of the [jenkins/inbound-agent](https://hub.docker.com/r/jenkins/inbound-agent) bundled with the Docker CLI. It is intended to be used for the Docker-out-of-Docker approach to executing Docker commands on the agent via docker.sock.

Docker-out-of-Docker exposes the host's Docker socket to a container allowing Docker commands to be executed on the host from the container. There is no docker engine running within the container.

## Build

Run the following command to build the image manually:

```
docker build -t anyssido/jenkins-inbound-docker-agent . --no-cache
```

# Usage

### Add a new node in Jenkins

1. Manage Jenkins > Manage Nodes and Clouds > New Node
2. Give your node a name. You will need this name later.
3. Select Permanent Agent.
4. Set Remote root directory to /home/jenkins/agent/
5. Ensure "Launch method" is set to the default of "Launch agent by connecting it to the controller."
6. Save

You are now ready to run the agent using one of the methods below.

## Docker run

```
docker run --init --privileged \
  -e JENKINS_URL=http://jenkins:8080 \
  -e JENKINS_AGENT_NAME=AgentName \
  -e JENKINS_SECRET=AgentSecret \
  -e JENKINS_WEB_SOCKET=true \
  -e TINI_SUBREAPER=true \
  -v /var/run/docker.sock:/var/run/docker.sock \
  anyssido/jenkins-inbound-docker-agent:latest
```

1. Replace the Jenkins url with your url.
2. Replace the agent name with the name you set earlier.
3. Replace the agent secret with your secret from the controller.
    - You can find this by clicking on your agent name on the Jenkins dashboard.

## Docker Compose

There are two docker-compose files included that you may use.

### Standalone

The standalone compose file will run just the agent. You will have to ensure that it is able to communicate with your jenkins instance.

1. Rename .env.example to .env
2. Open .env in a text editor and replace the values with your own.
3. Save

Now run the following command:

```
docker-compose -f docker-compose.standalone.yml up -d
```

### Jenkins + Agent

The default compose file will launch an instance of Jenkins along with the agent. They will both run within the same Docker network and the Jenkins URL has already been configured. You just need to add the agent name and secret.

1. Rename .env.example to .env
2. Open .env in a text editor and replace the values with your own.
3. Save.

Run the following command:

```
docker-compose up -d
```

Both Jenkins and the agent will be started. Jenkins will be accessible to your host at localhost:8083.

Complete the Jenkins setup and then add the agent using the [usage](#usage) steps above.
