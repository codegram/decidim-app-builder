var express = require('express');
var GithubWebHook = require('express-github-webhook');
var webhookHandler = GithubWebHook({ path: '/', secret: process.env.GITHUB_SECRET });
var bodyParser = require('body-parser');

var app = express();

var buildApp = require('./lib/build-app.js');

app.use(bodyParser.json());
app.use(webhookHandler);

webhookHandler.on('push', buildApp);

app.listen(4567, function () {
  console.log('Example app listening on port 4567!');
});
