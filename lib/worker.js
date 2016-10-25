var redis = require("redis");
var client = redis.createClient(process.env.REDIS_URL);
var moment = require('moment');
var uuid = require('node-uuid');
var buildApp = require('./build-app');

function processJob () {
  client.lpop("jobs", function (err, jobId) {
    if (jobId) {
      console.log("Processing job " + jobId + "...");
      client.get("job-" + jobId, function (err, data) {
        var parsedData = JSON.parse(data);

        parsedData.startAt = moment().format('MMMM Do YYYY, h:mm:ss a');

        client.set("job-" + jobId, JSON.stringify(parsedData), function () {
          buildApp(parsedData.githubUrl, parsedData.headCommit, function () {
            parsedData.endAt = moment().format('MMMM Do YYYY, h:mm:ss a');

            client.set("job-" + jobId, JSON.stringify(parsedData), function () {
              console.log("Finished job " + jobId + "...");
              processJob();
            });
          });
        });
      });
    } else {
      processJob();
    }
  });
}

function run () {
  console.log("Start worker process...");
  processJob();
}

function enqueue(githubUrl, headCommit) {
  var jobId = uuid.v1();

  console.log("Enqueue job " + jobId + "...");
  client.set("job-" + jobId, JSON.stringify({
    githubUrl: githubUrl,
    headCommit: headCommit
  }), function () {
    client.expire("job-" + jobId, 86400, function (err, data) {
      client.lpush("jobs", jobId);
    });
  });
}

function list() {
  var promise = new Promise(function (resolve, reject) {
    client.keys("job-*", function (err, keys) {
      Promise.all(
        keys.map(function (key) {
          var promise = new Promise(function (resolve, reject) {
            var matches = key.match(/job-(.*)/);
            var jobId = matches[1];

            client.get("job-" + jobId, function (err, data) {
              var parsedData = JSON.parse(data);
              parsedData.id = jobId;
              resolve(parsedData);
            });
          });
          return promise;
        })
      ).then(function (jobs) {
        return jobs.sort(function (a, b) {
          return moment(b.startAt, 'MMMM Do YYYY, h:mm:ss a').diff(moment(a.startAt, 'MMMM Do YYYY, h:mm:ss a'));
        });
      }).then(resolve);
    });
  });

  return promise;
}

module.exports = {
  run: run,
  process: process,
  enqueue: enqueue,
  list: list
};