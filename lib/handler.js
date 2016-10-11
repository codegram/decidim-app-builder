var worker = require('./worker');

module.exports = function (repo, data) {
  if (repo === "decidim" && data.ref === `refs/heads/${process.env.GITHUB_BRANCH}`) {
    var githubUrl = data.repository.clone_url;
    var headCommit = data.head_commit.id;

    worker.enqueue(githubUrl, headCommit);
  }
};