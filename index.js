var express = require('express');
var app = express();

app.get('/', function (req, res) {
  res.send('Hello World!');
});

app.listen(4567, function () {
  console.log('Example app listening on port 4567!');
});
