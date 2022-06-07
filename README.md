# Jenkins Inbound Agent with Docker CLI

This docker image is an extension of the [jenkins/inbound-agent](https://hub.docker.com/r/jenkins/inbound-agent) bundled with the Docker CLI. It is intended to be used for the Docker-out-of-Docker approach to executing Docker commands on the agent via docker.sock.

Docker-out-of-Docker exposes the host's Docker socket to a container allowing Docker commands to be executed on the host from the container. There is no docker engine running within the container.

- [Quickstart](#quickstart)
  - [Requirements](#requirements)
  - [Docker Compose](#docker-compose)
  - [Docker CLI](#docker-cli)
- [How to](#how-to)
  - [Run the agent and Jenkins together](#run-the-agent-and-jenkins-together)
  - [Add an agent in Jenkins](#add-an-agent-in-jenkins)
  - [Build the image manually](#build-the-image-manually)
  - [Build the image via Jenkins](#build-the-image-via-jenkins)

---

## Quickstart

### Requirements

[jenkins/inbound-agent](https://hub.docker.com/r/jenkins/inbound-agent) currently requires the cgroup namespace mode `host` set
for the container, which is not the default on cgroup v2 docker hosts anymore. It also cannot be specified with the latest docker-compose spec yet.
As a workaround you could change the `default-cgroupns-mode` of the docker deamon to `host` or bind the volumes to the same absolute path on the host (`/home/jenkins/agent`) instead of using docker volumes.

### Docker-compose

Use the included docker-compose.yml or add the service to your existing compose setup:

```yml
version: '3.8'

services:
  jenkins-inbound-agent:
    image: anyssido/jenkins-inbound-docker-agent
    init: true
    privileged: true
    environment:
      - JENKINS_URL=${JENKINS_URL}
      - JENKINS_AGENT_NAME=${JENKINS_AGENT_NAME}
      - JENKINS_SECRET=${JENKINS_SECRET}
      - JENKINS_WEB_SOCKET=true
      - TINI_SUBREAPER=true
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
```

A .env.example file has been provided that can be used to populate the required values.

```ini
# The url of your jenkins installation
JENKINS_URL=http://jenkins:8080

# The agent name you used when adding an agent to jenkins
JENKINS_AGENT_NAME=Smith

# The secret that is shown when you click your agent on the Jenkins dashboard
JENKINS_SECRET=2ca9231f9bb1bac6049184a34c58164cec949965c2a59e476c5d18cf905ab4f6
```

### Docker CLI

Run the following command after replacing JENKINS_URL, JENKINS_AGENT_NAME and JENKINS_SECRET:

```console
docker run --init --privileged \
  -e JENKINS_URL=http://jenkins:8080 \
  -e JENKINS_AGENT_NAME=AgentName \
  -e JENKINS_SECRET=AgentSecret \
  -e JENKINS_WEB_SOCKET=true \
  -e TINI_SUBREAPER=true \
  -v /var/run/docker.sock:/var/run/docker.sock \
  anyssido/jenkins-inbound-docker-agent:latest
```

## How to

### Run with Docker Compose

1. Rename .env.example to .env
2. Open .env in a text editor and replace the values with your own.
3. Save

Now run the following command:

```
docker-compose up -d
```

The agent will start and connect to Jenkins.

### Run the agent and Jenkins together

To run both the agent and Jenkins together you can use the following docker-compose template. Both containers will run within the same shared network and the Jenkins url is already configured. You just need to provide the agent name and agent secret.

```yml
version: '3.8'

networks:
  jenkins:
volumes:
  jenkins-data:

services:
  controller:
    image: jenkins/jenkins:lts
    privileged: true
    user: root
    networks:
      - jenkins
    ports:
      - 8083:8080
      - 50000:50000
    volumes:
      - "jenkins-data:/var/jenkins_home"

  inbound-agent:
    image: anyssido/jenkins-inbound-docker-agent
    init: true
    privileged: true
    environment:
      - JENKINS_URL=http://controller:8080
      - JENKINS_AGENT_NAME=${JENKINS_AGENT_NAME}
      - JENKINS_SECRET=${JENKINS_SECRET}
      - JENKINS_WEB_SOCKET=true
      - TINI_SUBREAPER=true
    networks:
      - jenkins
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
```

Jenkins can be accessed from your host at localhost:8083.

### Add an agent in Jenkins

You will need to add a new agent node in Jenkins before this agent can connect.

1. Manage Jenkins > Manage Nodes and Clouds > New Node
2. Give your node a name. You will need this name later.
3. Select Permanent Agent.
4. Set Remote root directory to /home/jenkins/agent/
5. Ensure "Launch method" is set to the default of "Launch agent by connecting it to the controller."
6. Save

You are now ready to run the agent using one of the methods above.

### Build the image manually

Run the following command to build the image manually:


```
docker build -t anyssido/jenkins-inbound-docker-agent . --no-cache
```

### Build the image via Jenkins

An example pipeline script is included in the .jenkins directory that can be used to build and publish this image.
