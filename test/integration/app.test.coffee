assert = require('assert')
request = require('request')
logmeup = require('../../app/logmeup')
config = require('../../config/config')
require('string')

T = (v) -> assert(v)
F = (v) -> assert(!v)

config.port = 7171

describe 'LogMeUp', ->
  describe 'when PUT /log/:collection/:app', ->
    it 'should create the database collection if it doesnt exist', (done) ->
      logmeup.init config: config, (err) ->
        T err is null
        logmeup.app.listen(config.port)

        collection = 'gitpilot' + Date.now() #not same as MongoDB collection
        app = 'servermonitor' + Date.now()

        request.put "http://localhost:#{config.port}/log/#{collection}/#{app}", (error, response, body) ->
          T body.startsWith('Created')
          T body.endsWith(collection + '_' + app)
          request.del "http://localhost:#{config.port}/log/#{collection}/#{app}", done #delete collection


    it 'should return an error message if the database collection does exist', (done) ->
      logmeup.init config: config, (err) ->
        T err is null
        logmeup.app.listen(config.port)

        collection = 'gitpilot' + Date.now() #not same as MongoDB collection
        app = 'servermonitor' + Date.now()

        request.put "http://localhost:#{config.port}/log/#{collection}/#{app}", (err, res, body) ->
          request.put "http://localhost:#{config.port}/log/#{collection}/#{app}", (err, res, body) ->
            T body.startsWith('Error')
            T body.contains('exists')
            request.del "http://localhost:#{config.port}/log/#{collection}/#{app}", done #delete collection


  describe 'when DELETE /log/:collection/:app', ->
    it 'should delete the database collection if it exists', (done) ->
      logmeup.init config: config, (err) ->
        T err is null
        logmeup.app.listen(config.port)

        collection = 'gitpilot' + Date.now()
        app = 'servermonitor' + Date.now()

        request.put "http://localhost:#{config.port}/log/#{collection}/#{app}", (err, res, body) ->
          T body.startsWith('Created')
          request.del "http://localhost:#{config.port}/log/#{collection}/#{app}", (err, res, body) ->
            T err is null
            T body.startsWith('Deleted')
            T body.endsWith(collection + '_' + app)
            done()

    it 'should return an error message if the database collection does not exist', (done) ->
      logmeup.init config: config, (err) ->
        T err is null
        logmeup.app.listen(config.port)

        collection = 'gitpilot' + Date.now()
        app = 'servermonitor' + Date.now()

        request.del "http://localhost:#{config.port}/log/#{collection}/#{app}", (err, res, body) ->
          T err is null
          T body.startsWith('Error')
          done()

  describe 'when POST /log/:collection/:app', ->
    it 'should insert the request body data into the database', (done) ->
      logmeup.init config: config, (err) ->
        T err is null
        logmeup.app.listen(config.port)

        collection = 'gitpilot' + Date.now()
        app = 'servermonitor' + Date.now()

        data = name: 'JP', lastName: 'Richardson'
        json = JSON.stringify(data)

        url = "http://localhost:#{config.port}/log/#{collection}/#{app}"
        request.put url, (err, res, body) ->
          request method: 'POST', headers: {'content-type': 'application/json'}, url: url, body: json, (err, res, body) ->
            T err is null
            T body.startsWith('Stored data')
            request.del "http://localhost:#{config.port}/log/#{collection}/#{app}", done #delete collection

    it 'should return an error message if the database collection does not exist', (done) ->
      logmeup.init config: config, (err) ->
        T err is null
        logmeup.app.listen(config.port)

        collection = 'gitpilot' + Date.now()
        app = 'servermonitor' + Date.now()

        data = name: 'JP', lastName: 'Richardson'
        json = JSON.stringify(data)

        url = "http://localhost:#{config.port}/log/#{collection}/#{app}"
        request method: 'POST', headers: {'content-type': 'application/json'}, url: url, body: json, (err, res, body) ->
          T err is null
          T body.startsWith('Error')
          T body.contains('does not exist')
          done()

  describe 'when GET /log/:collection/:app', ->
    it 'should show the page that contains the log data', (done) ->
      logmeup.init config: config, (err) ->
        T err is null
        logmeup.app.listen(config.port)

        collection = 'gitpilot' + Date.now()
        app = 'servermonitor' + Date.now()

        request.put "http://localhost:#{config.port}/log/#{collection}/#{app}", (err, res, body) ->
          request.get "http://localhost:#{config.port}/log/#{collection}/#{app}", (err, res, body) ->
            T err is null
            T body.contains('Log data')
            request.del "http://localhost:#{config.port}/log/#{collection}/#{app}", done #delete collection

    it 'should return an error message if the database collection does not exist', (done) ->
      logmeup.init config: config, (err) ->
        T err is null
        logmeup.app.listen(config.port)

        collection = 'gitpilot' + Date.now()
        app = 'servermonitor' + Date.now()

        request.get "http://localhost:#{config.port}/log/#{collection}/#{app}", (err, res, body) ->
          T err is null
          T body.startsWith('Error')
          T body.contains('does not exist')
          done()
  
  describe 'when GET /log/data/:collection/:app', ->
    it 'should return an error if the database collection does not exist', (done) ->
      logmeup.init config: config, (err) ->
        T err is null
        logmeup.app.listen(config.port)

        collection = 'gitpilot' + Date.now()
        app = 'servermonitor' + Date.now()

        request.get "http://localhost:#{config.port}/log/data/#{collection}/#{app}", (err, res, body) ->
          T err is null
          T body.startsWith('Error')
          T body.contains('does not exist')
          done()

    it 'should return JSON sorted (DESC by date) records in an array with the count of the total number of records', (done) ->
      logmeup.init config: config, (err) ->
        T err is null
        logmeup.app.listen(config.port)

        collection = 'gitpilot' + Date.now()
        app = 'servermonitor' + Date.now()

        insertRecord = (data,callback) -> #convenience method to insertData
          json = JSON.stringify(data)
          url = "http://localhost:#{config.port}/log/#{collection}/#{app}"
          request method: 'POST', headers: {'content-type': 'application/json'}, url: url, body: json, (err, res, body) ->
            #console.log body
            T body.startsWith('Stored data')
            callback()

        request.put "http://localhost:#{config.port}/log/#{collection}/#{app}", (err, res, body) ->
          #request.get "http://localhost:#{config.port}/log/data/#{collection}/#{app}", (err, res, body) ->
          RECORD_COUNT = 10
          recur = (count) -> #this is so all the insertData requests don't happen simultaneously
            if count < RECORD_COUNT
              data = someNumber: Math.random(), someOtherValue: 'rarrr!'
              insertRecord data, ->
                if count < RECORD_COUNT - 1
                 recur(count+1)
                else
                  request.get "http://localhost:#{config.port}/log/data/#{collection}/#{app}", (err, res, body) ->
                    data = JSON.parse(body)
                    T data.total is RECORD_COUNT
                    T data.records.length is RECORD_COUNT
                    T data.records[0].created_at > data.records[1].created_at > data.records[2].created_at 
                    request.del "http://localhost:#{config.port}/log/#{collection}/#{app}", done #delete collection
          recur(0)

                



