#request = require('request')
logmeup = require('../../app/logmeup')
config = require('../../config/config')
S = require('string')
request2 = require('superagent')
require('testutil')


config.port = 7171

describe 'LogMeUp', ->

  collection = 'gitpilot' + Date.now()
  app = 'servermonitor' + Date.now()

  beforeEach (done) ->
    logmeup.init config: config, (err) ->
      T err is null
      logmeup.app.listen(config.port)
      request2.del("http://localhost:#{config.port}/log/#{collection}/#{app}").end -> done()

  afterEach (done) ->
    logmeup.app.close()
    done()

  describe 'when PUT /log/:collection/:app', ->
    it 'should create the database collection if it doesnt exist', (done) ->
      request2.put("http://localhost:#{config.port}/log/#{collection}/#{app}").end (res) ->
        console.log res.text
        T S(res.text).startsWith('Created')
        T S(res.text).endsWith(collection + '_' + app)
        done()

    it 'should return an error message if the database collection does exist', (done) ->
      request2.put("http://localhost:#{config.port}/log/#{collection}/#{app}").end (res) ->
        request2.put("http://localhost:#{config.port}/log/#{collection}/#{app}").end (res) ->
          T S(res.text).startsWith('Error')
          T S(res.text).contains('exists')
          done()

  describe 'when DELETE /log/:collection/:app', ->
    it 'should delete the database collection if it exists', (done) ->
      request2.put("http://localhost:#{config.port}/log/#{collection}/#{app}").end (res) ->
        T S(res.text).startsWith('Created')
        request2.del("http://localhost:#{config.port}/log/#{collection}/#{app}").end (res) ->
          #T err is null
          T S(res.text).startsWith('Deleted')
          T S(res.text).endsWith(collection + '_' + app)
          done()

    it 'should return an error message if the database collection does not exist', (done) ->
      request2.del("http://localhost:#{config.port}/log/#{collection}/#{app}").end (res) ->
        #T err is null
        T S(res.text).startsWith('Error')
        done()

  describe 'when POST /log/:collection/:app', ->
    it 'should insert the request body JSON data into the database', (done) ->
      data = name: 'JP', lastName: 'Richardson'

      url = "http://localhost:#{config.port}/log/#{collection}/#{app}"
      request2.put(url).end (res) ->
        request2.post(url).type('json').send(data).end (res) -> #application/json
          #T err is null
          T S(res.text).startsWith('Stored data')
          done()

    it 'should insert the request body Form data into the database', (done) ->
      d = data: 'JP Richardson' #must use 'data' key

      url = "http://localhost:#{config.port}/log/#{collection}/#{app}"
      request2.put(url).end (res) ->
        request2.post(url).set('Content-Type':'application/x-www-form-urlencoded').send(d).end (res) -> #BUG IN SUPERAGENT, in browser it's 'form-data' #application/x-www-form-urlencoded
          #T err is null
          T S(res.text).startsWith('Stored data')
          done() 

    it 'should return an error message if the database collection does not exist', (done) ->
      data = name: 'JP', lastName: 'Richardson'

      url = "http://localhost:#{config.port}/log/#{collection}/#{app}"
      request2.post(url).type('json').send(data).end (res) ->
        #T err is null
        T S(res.text).startsWith('Error')
        T S(res.text).contains('does not exist')
        done()

  describe 'when GET /log/:collection/:app', ->
    it 'should show the page that contains the log data', (done) ->
      request2.put("http://localhost:#{config.port}/log/#{collection}/#{app}").end (res) ->
        request2.get("http://localhost:#{config.port}/log/#{collection}/#{app}").end (res) ->
          #T err is null
          #console.log res.text
          #exit()
          T S(res.text).contains('Log data')
          done()

    it 'should return an error message if the database collection does not exist', (done) ->
      request2.get("http://localhost:#{config.port}/log/#{collection}/#{app}").end (res) ->
        #T err is null
        T S(res.text).startsWith('Error')
        T S(res.text).contains('does not exist')
        done()
  
  describe 'when GET /log/:collection/:app/data.json', ->
    it 'should return an error if the database collection does not exist', (done) ->
      request2.get("http://localhost:#{config.port}/log/#{collection}/#{app}/data.json").end (res) ->
        T S(res.text).startsWith('Error')
        T S(res.text).contains('does not exist')
        done()

    it 'should return JSON sorted (DESC by date) records in an array with the count of the total number of records', (done) ->
      insertRecord = (data,callback) -> #convenience method to insertData
        url = "http://localhost:#{config.port}/log/#{collection}/#{app}"
        request2.post(url).type('json').send(data).end (res) ->
          #console.log body
          T S(res.text).startsWith('Stored data')
          callback()

      request2.put("http://localhost:#{config.port}/log/#{collection}/#{app}").end (res) ->
        RECORD_COUNT = 10
        recur = (count) -> #this is so all the insertData requests don't happen simultaneously
          if count < RECORD_COUNT
            data = someNumber: Math.random(), someOtherValue: 'rarrr!'
            insertRecord data, ->
              if count < RECORD_COUNT - 1
               recur(count+1)
              else
                request2.get("http://localhost:#{config.port}/log/#{collection}/#{app}/data.json").end (res) ->
                  data = res.body
                  T data.total is RECORD_COUNT
                  T data.records.length is RECORD_COUNT
                  T data.records[0].created_at > data.records[1].created_at > data.records[2].created_at 
                  request2.del("http://localhost:#{config.port}/log/#{collection}/#{app}").end -> done() #delete collection
        recur(0)

                



