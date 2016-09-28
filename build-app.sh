#!/bin/bash

DECIDIM_GITHUB_URL=$1
DECIDIM_GITHUB_COMMIT_ID=$2

DECIDIM_APP_NAME="decidim-testapp"
TEMP_PATH="/tmp"
DECIDIM_PATH="$TEMP_PATH/decidim"
DECIDIM_APP_PATH="$TEMP_PATH/$DECIDIM_APP_NAME"

RANCHER="/tmp/rancher-$RANCHER_VERSION/rancher"
DOCKER="$RANCHER --host decidim docker"

RANCHER_STACK="decidim-testapp"
RANCHER_SERVICE="app"

rm -rf $DECIDIM_PATH
rm -rf $DECIDIM_APP_PATH

git clone $DECIDIM_GITHUB_URL $DECIDIM_PATH
cd $DECIDIM_PATH && git checkout $DECIDIM_GITHUB_COMMIT_ID

$DOCKER login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

$DOCKER build -t codegram/decidim $DECIDIM_PATH

$DOCKER push codegram/decidim
 
$DOCKER run --rm -v $TEMP_PATH:/tmp codegram/decidim /tmp/$DECIDIM_APP_NAME
 
$DOCKER build -t codegram/$DECIDIM_APP_NAME $DECIDIM_PATH/$DECIDIM_APP_NAME
 
$DOCKER push codegram/$DECIDIM_APP_NAME

$RANCHER up -s $RANCHER_STACK -u -c -d -p $RANCHER_SERVICE