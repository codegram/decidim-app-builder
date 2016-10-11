var express = require('express');
var GithubWebHook = require('express-github-webhook');
var webhookHandler = GithubWebHook({ path: '/', secret: process.env.GITHUB_SECRET });
var bodyParser = require('body-parser');

var app = express();

var handler = require('./lib/handler');
var worker = require('./lib/worker');

worker.run();

app.use(bodyParser.json());
app.use(webhookHandler);

webhookHandler.on('push', handler);

app.get('/', function (req, res) {
  handler('decidim', { ref: 'refs/heads/master', repository: {
    clone_url: 'dontcare'
  }, head_commit: {
    id: '123456'
  }});
  res.send("OK");
});

app.listen(4567, function () {
  console.log('Example app listening on port 4567!');
});
