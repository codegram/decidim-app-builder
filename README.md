# Decidim App builder

This applications runs a simple express.js server which can listen github push webhooks.

You need to provide a couple of environment variables:
- `GITHUB_BRANCH`: Just listen push webhook events on this branch.
- `GITHUB_SECRET`: Webhook secret to decrypt github payload.

## How it works

When a webhook is received the applications runs the `build-app.sh` script. This script perfoms the following steps:

1. Clone the github repo and move the HEAD to the last branch commit.
2. Build `decidim` docker image and push it to Docker Hub.
3. Use the previous image to run `decidim` generator and creates a test application.
4. Build decidim test application docker image and push it to Docker Hub.
5. Use rancher CLI to upgrade the service running decidim test application.

The script itself is running Docker through a Rancher host and it can be highly configured using the script environment variables.

## Build docker image

In order to build the docker image you need some credentials. Rancher credentials can be found on `$HOME/.rancher/cli.json` and Docker credentials on `$HOME/.docker/config.json`.

```
docker build --build-arg rancherAccessKey=xxxx 
             --build-arg rancherSecretKey=xxxx
             --build-arg rancherUrl=xxxx
             --build-arg dockerAuth=xxxx
             -t codegram/decidim-app-builder .
```

Since the image is storing sensitive data it is recommended to use a private docker registry.

## Roadmap

- Create some kind of queue in order to handle multiple webhooks.
- Support for multi-deployments.

## License

MIT License, see LICENSE for details. Copyright 2012-2016 Codegram Technologies.