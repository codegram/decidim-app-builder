FROM node:6.6.0
MAINTAINER david.morcillo@codegram.com

ARG rancherAccessKey=
ARG rancherSecretKey=
ARG rancherUrl=

ENV APP_HOME /code
ENV RANCHER_VERSION v0.1.0
ENV RANCHER_ACCESS_KEY $rancherAccessKey
ENV RANCHER_SECRET_KEY $rancherSecretKey
ENV RANCHER_URL $rancherUrl

RUN apt-get update && apt-get install -y wget apt-transport-https ca-certificates

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y docker-engine

RUN npm install -g nodemon

RUN mkdir -p $HOME/.rancher && \
    echo "{\"accessKey\":\"$RANCHER_ACCESS_KEY\",\"secretKey\":\"$RANCHER_SECRET_KEY\",\"url\":\"$RANCHER_URL\",\"environment\":\"1a5\"}" > $HOME/.rancher/cli.json

RUN cd /tmp && \
    wget https://github.com/rancher/cli/releases/download/$RANCHER_VERSION/rancher-linux-amd64-$RANCHER_VERSION.tar.gz && \
    tar -xzvf rancher-linux-amd64-$RANCHER_VERSION.tar.gz

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME

CMD npm start
