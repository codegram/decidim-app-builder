FROM node:6.6.0
MAINTAINER david.morcillo@codegram.com

ARG githubSecret=
ARG githubBranch=master
ARG rancherAccessKey=
ARG rancherSecretKey=
ARG rancherUrl=

ENV APP_HOME /code
ENV GITHUB_SECRET $githubSecret
ENV GITHUB_BRANCH $githubBranch
ENV RANCHER_VERSION v0.1.0
ENV RANCHER_ACCESS_KEY $rancherAccessKey
ENV RANCHER_SECRET_KEY $rancherSecretKey
ENV RANCHER_URL $rancherUrl

RUN apt-get update && apt-get install wget

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
