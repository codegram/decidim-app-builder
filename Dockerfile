FROM node:6.6.0
MAINTAINER david.morcillo@codegram.com

ARG rancherAccessKey=
ARG rancherSecretKey=
ARG rancherUrl=
ARG dockerAuth=

ENV APP_HOME /code

ENV RANCHER_VERSION v0.1.0

RUN apt-get update && apt-get install -y wget apt-transport-https ca-certificates

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y docker-engine

RUN npm install -g nodemon

RUN mkdir -p $HOME/.rancher && \
    echo "{\"accessKey\":\"$rancherAccessKey\",\"secretKey\":\"$rancherSecretKey\",\"url\":\"$rancherUrl\",\"environment\":\"1a5\"}" > $HOME/.rancher/cli.json

RUN mkdir -p $HOME/.docker && \
    echo "{\"auths\":{\"https://index.docker.io/v1/\": {\"auth\":\"$dockerAuth\",\"email\":\"david.morcillo@gmail.com\"}}}" > $HOME/.docker/config.json

RUN cd /tmp && \
    wget https://github.com/rancher/cli/releases/download/$RANCHER_VERSION/rancher-linux-amd64-$RANCHER_VERSION.tar.gz && \
    tar -xzvf rancher-linux-amd64-$RANCHER_VERSION.tar.gz

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME

CMD npm start
