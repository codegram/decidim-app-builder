var util  = require('util'),
    spawn = require('child_process').spawn;

module.exports = function (githubUrl, headCommit, cb) {
  var cmd = spawn('./build-app-test.sh', [githubUrl, headCommit]);

  cmd.stdout.on('data', function (data) {
    console.log('stdout: ' + data.toString());
  });

  cmd.stderr.on('data', function (data) {
    console.log('stderr: ' + data.toString());
  });

  cmd.on('exit', function (code) {
    console.log('child process exited with code ' + code.toString());
    cb();
  });
};