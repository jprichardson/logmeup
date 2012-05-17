if window? #hack to test if in browser, thus test-server.sh won't run this file
  request = superagent

  describe 'log', ->
    collection = 'gitpilotllc'
    app = 'macclient'
    url = window.location.origin + "/log/#{collection}/#{app}"

    beforeEach (done) -> #doesn't work
      request.del(url).end -> done()

    describe 'when browser navigates to log/:collection/:app', ->
      it 'should show the most recent data', (done) ->      
        request.put(url).end (res) ->
          if S(res.text).startsWith('Error') then throw new Error(res.text)
          T S(res.text).startsWith('Created')
          T S(res.text).endsWith(collection + '_' + app)

          insertRecord = (data,callback) -> #convenience method to insert data
            request.post(url).send(data).end (res) ->
              T S(res.text).startsWith('Stored data')
              callback()

          dataArray = []
          RECORD_COUNT = 10
          recur = (count) -> #this is so all the insertRecord requests don't happen simultaneously
            if count < RECORD_COUNT
              data = message: "A log message..." + count, someNumber: Math.random()
              dataArray.push data
              insertRecord data, ->
                if count < RECORD_COUNT - 1
                  recur(count+1)
                else
                  logmeup.fetchLogData collection, app, (responseData) ->
                    dataEl = document.createElement('div'); dataEl.id = 'data'
                    logmeup.addDataToPage dataEl, responseData, ->
                      childrenEls = dataEl.childNodes
                      T responseData.records.length == childrenEls.length == RECORD_COUNT
                      for i in [0...childrenEls.length]
                        T childrenEls[childrenEls.length - i - 1].innerText.contains(dataArray[i].message) #because elements are DESC
                      done()
          recur(0)

    describe 'when new data is logged, page at log/:collection/:app should receive the data through WebSockets', ->
      it 'should recieve new data', (done) ->
        logmeup.setupSocket(window.location.origin, collection, app)

        request.put(url).end (res) ->
          if S(res.text).startsWith('Error') then throw new Error(res.text)
          T S(res.text).startsWith('Created')

          insertRecord = (data,callback) -> #convenience method to insert data
            request.post(url).send(data).end (res) ->
              T S(res.text).startsWith('Stored data')
              if callback? then callback()

          INSERT_COUNT = 5
          counter = 0

          logmeup.on 'data', (data) ->
            #alert data.msg
            T S(data.data.msg).contains("Some crazy message")
            counter += 1
            if counter is INSERT_COUNT
              done()

          for i in [0...INSERT_COUNT] #pretty much execute these at the same time
            insertRecord(msg: "Some crazy message..." + i)



