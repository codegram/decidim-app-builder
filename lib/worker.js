var redis = require("redis");
var client = redis.createClient(process.env.REDIS_URL);

var buildApp = require('./build-app');

function processJob () {
  client.lpop("jobs", function (err, jobId) {
    if (jobId) {
      console.log("Processing job " + jobId + "...");
      client.get("job-" + jobId, function (err, data) {
        var parsedData = JSON.parse(data);

        buildApp(data.githubUrl, data.headCommit, function () {
          parsedData.endAt = +new Date();

          client.set("job-" + jobId, JSON.stringify(parsedData), function () {
            console.log("Finished job " + jobId + "...");
            processJob();  
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
  var startAt = +new Date();
  var jobId = headCommit + '-' + startAt + '-' + Math.ceil(Math.random() * 100000000);

  console.log("Enqueue job " + jobId + "...");
  client.set("job-" + jobId, JSON.stringify({
    startAt: startAt,
    githubUrl: githubUrl,
    headCommit: headCommit
  }), function () {
    client.lpush("jobs", jobId);
  });
}

module.exports = {
  run: run,
  process: process,
  enqueue: enqueue
};