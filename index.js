var express = require('express');
var GithubWebHook = require('express-github-webhook');
var webhookHandler = GithubWebHook({ path: '/', secret: process.env.GITHUB_SECRET });
var bodyParser = require('body-parser');

var sys = require('sys')
var exec = require('child_process').exec;

var app = express();

app.use(bodyParser.json());
app.use(webhookHandler);

webhookHandler.on('push', function (repo, data) {
  console.log(repo);
  console.log(data.ref);
  console.log(process.env.GITHUB_BRANCH);
  if (repo === "decidim" && data.ref === `refs/heads/${process.env.GITHUB_BRANCH}`) {
    var githubUrl = data.repository.clone_url;
    var headCommit = data.head_commit.id;

    exec(`./build-app.sh ${githubUrl} ${headCommit}`, function (err, stdout, stderr) {
      if (err) {
        console.error(err);
      } else {
        console.log(stdout);
      }
    });
  }
});

app.listen(4567, function () {
  console.log('Example app listening on port 4567!');
});
