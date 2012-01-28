require('../../extensions/date')
mongo = require('mongodb')
{Db} = mongo
{Connection} = mongo
{Server} = mongo

database = require('../database')

host = 'localhost'
port = 27017
DBNAME = 'logmeup'

sockets = null
recordsPerPage = 100

exports.configure = (db, io, recsPerPage) ->
  database.workingDatabase = db
  sockets = io.sockets
  recordsPerPage = recsPerPage

exports.index = (req, res) ->
  res.render('index', { title: 'LogMeUp' })

exports.create = (req, res) ->
  colName = req.params.org + '_' + req.params.app
  #console.log colName
  database.collection.create name: colName, (err,col) ->
    #console.log err
    if err?
      res.send 'Error: ' + err.message
    else
      res.send 'Created: ' + colName

exports.delete = (req, res) ->
  colName = req.params.org + '_' + req.params.app
  database.collection.drop name: colName, (err) ->
    if err?
      res.send 'Error: ' + err.message
    else
      res.send 'Deleted: ' + colName

exports.store = (req, res) ->
  colName = req.params.org + '_' + req.params.app
  db = database.workingDatabase
  db.collection colName, (err, collection) ->
    if err?
      res.send 'Error: ' + err.message
    else
      data = created_at: (new Date()).getUTCTime(), data: req.body
      collection.insert data, {safe: true}, (err, docs) ->
        if err?
          res.send 'Error storing: ' + err.message
        else
          sockets.emit(colName, JSON.stringify(data))
          res.send 'Stored data.'
        
exports.show = (req, res) ->
  colName = req.params.org + '_' + req.params.app
  db = database.workingDatabase
  db.collection colName, (err, collection) ->
    if err?
      res.send 'Error: ' + err.message
    else
      #collection.find {}, (err, cursor) ->
      #  if err?
      #    res.send 'Error storing: ' + err.message
      #  else
          ###
          setTimeout(->
            cursor.each (err,doc) ->
              if doc?
                #buf += 'Data: ' + doc.data + '<br/>'
                console.log JSON.stringify(doc)
                sockets.emit('news', JSON.stringify(doc))
          ,250)
          ###
      res.render('show', {title: colName})

exports.data = (req, res) ->
  colName = req.params.org + '_' + req.params.app
  db = database.workingDatabase
  db.collection colName, (err, col) ->
    if err?
      res.send 'Error: ' + err.message
    else
      col.find({}).count (err, total) ->
        responseData = total: total, records: []
        fields = created_at: true, data: true, _id: true
        options = limit: recordsPerPage, sort: [['created_at', 'desc']]
        col.find({},fields,options).toArray (err,docs) ->
          responseData.records = docs
          res.header("Content-Type", "application/json");
          res.send JSON.stringify(responseData)



