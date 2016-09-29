var util  = require('util'),
    spawn = require('child_process').spawn;

module.exports = function (repo, data) {
  if (repo === "decidim" && data.ref === `refs/heads/${process.env.GITHUB_BRANCH}`) {
    var githubUrl = data.repository.clone_url;
    var headCommit = data.head_commit.id;

    var cmd = spawn('./build-app.sh', [githubUrl, headCommit]);

    cmd.stdout.on('data', function (data) {
      console.log('stdout: ' + data.toString());
    });

    cmd.stderr.on('data', function (data) {
      console.log('stderr: ' + data.toString());
    });

    cmd.on('exit', function (code) {
      console.log('child process exited with code ' + code.toString());
    });
  }
};