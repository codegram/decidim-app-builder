FROM node:6.6.0
MAINTAINER david.morcillo@codegram.com

ARG rancherAccessKey=
ARG rancherSecretKey=
ARG rancherUrl=
ARG dockerAuth=

ENV APP_HOME /code

ENV RANCHER_VERSION v0.6.1

RUN apt-get update && apt-get install -y wget apt-transport-https ca-certificates

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y docker-engine

RUN npm install -g nodemon

RUN mkdir -p $HOME/.rancher && \
    echo "{\"accessKey\":\"$rancherAccessKey\",\"secretKey\":\"$rancherSecretKey\",\"url\":\"$rancherUrl\",\"environment\":\"1a5\"}" > $HOME/.rancher/cli.json

RUN mkdir -p $HOME/.docker && \
    echo "{\"auths\":{\"https://index.docker.io/v1/\": {\"auth\":\"$dockerAuth\",\"email\":\"david.morcillo@gmail.com\"}}}" > $HOME/.docker/config.json

RUN mkdir -p /rancher && \
    cd /rancher && \
    wget https://github.com/rancher/cli/releases/download/$RANCHER_VERSION/rancher-linux-amd64-$RANCHER_VERSION.tar.gz && \
    tar -xzvf rancher-linux-amd64-$RANCHER_VERSION.tar.gz

# Set the timezone.
RUN echo "Europe/Madrid" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN mkdir -p $APP_HOME

ADD package.json /tmp
RUN cd /tmp && npm install && cp -r /tmp/node_modules $APP_HOME

WORKDIR $APP_HOME
ADD . $APP_HOMEk

CMD npm start
