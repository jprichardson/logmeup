#!/usr/bin/env coffee

path = require('path')
process.env['NODE_ENV'] = 'testing'
require(path.join(__dirname,'../app'))