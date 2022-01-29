FROM jenkins/inbound-agent:latest

LABEL description="Inbound agent for Jenkins with docker cli pre-installed for use via docker.sock." \
      maintainer="Anys Sido <anys.dev@gmail.com>"
      
USER root

# Setup Docker repository
RUN apt-get update
RUN apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Install Docker CLI
RUN apt-get update && apt-get install -y docker-ce-cli