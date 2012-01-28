###
This class serves as a simple wrapper for the MongoDB driver. It feels a bit overly verbose, maybe even a bit unnecessary. Probably should consider refactoring.
###

mongo = require('mongodb')
{Db} = mongo
{Connection} = mongo
{Server} = mongo
require('string')

module.exports = database = {workingDatabase: null, collection: {}}
collection = database.collection


# DATABASE

database.connect = (options = {}, callback) ->
  if options.config?
    options = options.config

  db = new Db(options.name, new Server(options.host, options.port, {}), {native_parser:false, strict:true})
  db.open (err, db) ->
    callback(err,db)

# COLLECTION

collection.create = (options = {}, callback) ->
  db = options.db ?= database.workingDatabase
  name = options.name 
  sizeInMb = options.sizeInMb ?= 10
  maxRecords = options.maxRecords ?= 75000
  db.createCollection name, {'capped':true, 'size':sizeInMb*1024*1024, 'max':maxRecords}, (err, collection) ->
    callback(err,db)

collection.drop = (params ={}, callback) ->
  db = params.db ?= database.workingDatabase
  name = params.name
  db.dropCollection name, (err) ->
    callback(err)

collection.exists = (params = {}, callback) ->
  db = params.db ?= database.workingDatabase
  name = params.name
  db.collectionNames (err,names) ->
    if err?
      callback(err, null)
    else
      exists = false
      for col in names
        #console.log JSON.stringify(col)
        if col.name.endsWith(name)
          exists = true
          break
      callback(null, exists)

collection.fetchProperties = (params = {}, callback) ->
  db = params.db ?= database.workingDatabase
  name = params.name
  db.collectionNames (err,cols) ->
    if err?
      callback(err, null)
    else
      myCol = null
      for col in cols
        if col.name.endsWith(name)
          myCol = col
          break
      if myCol?
        props = myCol.options
        props.maxRecords = props.max ?= null
        props.sizeInMb = props.size / (1024*1024)
        props.name = myCol.name
        delete props.size; delete props.max
        callback(null, props)
      else
        callback(new Error('Collection not found.'),null)


 