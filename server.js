'use strict';

const express = require('express');
const PORT = 8080;

const app = express();

app.get('/', function(req, res) {
  console.log('Should have the redis host exposed', process.env.REDIS_HOST, process.env.REDIS_PORT)
  res.send('Hello world');
});

app.listen(PORT);
console.log('Running on http://0.0.0.0:'+PORT);
