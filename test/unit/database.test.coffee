database = require('../../app/database')
assert = require('assert')
config = require('../../config/config')
require('string')

T = (v) -> assert(v)
F = (v) -> assert(!v)

dbcfg = config.database.testing

############
# DATABASE
############

describe 'database', ->

  beforeEach (done) ->
    database.connect config: dbcfg, (err,db) ->
      #db.close()
      #db.dropDatabase()
      done()

  afterEach (done) ->
    database.workingDatabase = null
    done()

  describe '+ connect()', ->
    it 'should return an instance of mongodb.db', (done) ->
      database.connect name: dbcfg.name, port: dbcfg.port, host: dbcfg.host, (err, db) ->
        T err is null
        T db isnt null
        db.close()
        done()
  
  describe '+ workingDatabase', ->
    it 'is an object property to hold the working database so that you dont have to specify it every method call', ->
      T database.workingDatabase isnt undefined #verify that it exists
      T database.workingDatabase is null
      database.workingDatabase = {}
      T database.workingDatabase isnt null

#############
# COLLECTION
#############

  describe 'collection', ->
    describe '+ create()', ->
      it 'should return an instance of mongodb.collection', (done) ->
        database.connect config: dbcfg, (err, db) ->
          database.workingDatabase = db
          someCol = 'someCollection_' + Date.now()
          database.collection.create name: someCol, maxRecords: 1000, sizeInMb: 1, (err, col) ->
            T err is null
            T col isnt null
            database.collection.drop name: someCol, done
      
      it 'should return an instance of mongodb.collection with default properties', (done) ->
        database.connect config: dbcfg, (err, db) ->
          database.workingDatabase = db
          someCol = 'someCollection_' + Date.now()
          database.collection.create name: someCol, (err, col) ->
            database.collection.fetchProperties name: someCol, (err, props) ->
              T props.sizeInMb is 10
              T props.maxRecords is 75000
              database.collection.drop name: someCol, done
    
    describe '+ drop()', ->
      it 'should drop (delete) the collection', (done) ->
        database.connect config: dbcfg, (err,db) ->
          database.workingDatabase = db
          someCol = 'someCollection_' + Date.now()
          database.collection.exists name: someCol, (err, exists1) ->
            F exists1
            database.collection.create name: someCol, (err, col) ->
              database.collection.exists name: someCol, (err, exists2) ->
                T exists2
                database.collection.drop name: someCol, (err) ->
                  database.collection.exists name: someCol, (err, exists3) ->
                    F exists3
                    done()


    describe '+ exists()', ->
      it 'should return true or false if the collection exists', (done) ->
        database.connect config: dbcfg, (err, db) ->
          database.workingDatabase = db
          someCol = 'someCollection_' + Date.now()
          database.collection.exists name: someCol, (err,trueOrFalse) ->
            F trueOrFalse
            database.collection.create name: someCol, (err,col) ->
              database.collection.exists name: someCol, (err,trueOrFalse) ->
                T trueOrFalse
                database.collection.drop name: someCol, done

    describe '+ fetchProperties()', ->
      it 'should return an object with the collection properties', (done) ->
        database.connect config: dbcfg, (err, db) ->
          database.workingDatabase = db
          someCol = 'someCollection_' + Date.now()
          database.collection.create name: someCol, maxRecords: 1000, sizeInMb: 1, (err, col) ->
            database.collection.fetchProperties name: someCol, (err, props) ->
              T err is null
              T props.name.endsWith(someCol)
              T props.capped isnt undefined
              T props.maxRecords isnt undefined
              T props.sizeInMb isnt undefined
              database.collection.drop name: someCol, done
      
      it 'should return an error if no collection is found', (done) ->
        database.connect config: dbcfg, (err, db) ->
          database.workingDatabase = db
          someCol = 'someCollection_' + Date.now()
          database.collection.fetchProperties name: someCol, (err, props) ->
            T err isnt null
            T err.message.indexOf('not found') > 0
            done()


