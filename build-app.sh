#!/bin/bash

DECIDIM_GITHUB_URL=$1
DECIDIM_GITHUB_COMMIT_ID=$2

DECIDIM_APP_NAME="decidim-testapp"
TEMP_PATH="/tmp"
DECIDIM_PATH="$TEMP_PATH/decidim"
DECIDIM_APP_PATH="$TEMP_PATH/$DECIDIM_APP_NAME"

RANCHER="/rancher/rancher-$RANCHER_VERSION/rancher"
DOCKER="$RANCHER --host decidim docker"

RANCHER_STACK="decidim-testapp"
RANCHER_APP_SERVICE="app"
RANCHER_NGINX_SERVICE="nginx"
RANCHER_DB_TASK_SERVICE="task-db-setup"
RANCHER_ASSETS_TASK_SERVICE="task-assets-precompile"

echo "Cleaning old folders..."
rm -rf $DECIDIM_PATH
rm -rf $DECIDIM_APP_PATH

echo "Cloning decidim repository..."
git clone $DECIDIM_GITHUB_URL $DECIDIM_PATH
cd $DECIDIM_PATH && git checkout $DECIDIM_GITHUB_COMMIT_ID

$DOCKER login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

echo "Building decidim docker image..."
$DOCKER build -t codegram/decidim $DECIDIM_PATH
$DOCKER push codegram/decidim
 
echo "Generating decidim test application..."
$DOCKER run --rm -e DECIDIM_APP_NAME=$DECIDIM_APP_NAME \
             -v $TEMP_PATH:/tmp \
             --log-opt max-size=50m \
             codegram/decidim \
             bundle exec bin/decidim --edge /tmp/$DECIDIM_APP_NAME
$DOCKER run --rm -e DECIDIM_APP_NAME=$DECIDIM_APP_NAME \
             -v $TEMP_PATH:/tmp \
             codegram/decidim \
             bash -c "cd /tmp/$DECIDIM_APP_NAME && bundle exec rails generate decidim:demo"
             
echo "Building decidim test application docker image..."
$DOCKER build --build-arg secret_key_base=1234 -t codegram/$DECIDIM_APP_NAME $TEMP_PATH/$DECIDIM_APP_NAME
$DOCKER push codegram/$DECIDIM_APP_NAME

echo "Exporting rancher stack config..."
$RANCHER export $RANCHER_STACK > $RANCHER_STACK.tar
tar -xvf $RANCHER_STACK.tar

echo "Stopping decidim test application service..."
$RANCHER stop --type service $RANCHER_APP_SERVICE

echo "Re-creating database..."
$RANCHER up -s $RANCHER_STACK --force-upgrade -c -d -p $RANCHER_DB_TASK_SERVICE

echo "Upgrading decidim test application service..."
$RANCHER up -s $RANCHER_STACK --force-upgrade -c -d -p $RANCHER_APP_SERVICE

echo "Upgrading nginx service..."
$RANCHER up -s $RANCHER_STACK --force-upgrade -c -d -p $RANCHER_NGINX_SERVICE

echo "Compiling assets..."
$RANCHER up -s $RANCHER_STACK --force-upgrade -c -d -p $RANCHER_ASSETS_TASK_SERVICE
