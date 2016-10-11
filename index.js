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

app.set('view engine', 'pug');

app.get('/jobs', function (req, res) {
  worker.list().then(function (jobs) {
    res.render('jobs', { jobs: jobs });
  });
});

app.listen(4567, function () {
  console.log('Example app listening on port 4567!');
});
