FROM node:6.6.0
MAINTAINER david.morcillo@codegram.com

ENV APP_HOME /code

RUN npm install -g nodemon

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME

CMD npm start
