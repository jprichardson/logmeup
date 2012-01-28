logmeup = window.logmeup = {}
logmeup.messages = {} #simple EventEmitter emulation... probably a better way to to do this


logmeup.convertToElement = (record) ->
  millis = record.created_at - (new Date()).getTimezoneOffset() * 60000 #convert UTC millis
  dt = new Date(millis)

  recEl = document.createElement('div')
  recEl.id = 'record-' + record['_id']
  recEl.innerHTML = '<b>' + dt.toLocaleDateString() + ' ' + dt.toLocaleTimeString() + '</b> ' +  JSON.stringify(record.data)
  recEl

logmeup.fetchLogData = (collection, app, callback) ->
  url = "#{window.location.origin}/log/data/#{collection}/#{app}" 
  $.getJSON url, (data) ->
    callback(data)

logmeup.addDataToPage = (element, data, callback) ->
  for rec in data.records
    recEl = logmeup.convertToElement(rec)
    element.appendChild(recEl)
  callback()
    
logmeup.setupSocket = (host, collection, app) ->
  socket = io.connect(host)
  socket.on collection + '_' + app, (data) ->
    if logmeup.messages['data']?
      logmeup.messages['data'](JSON.parse(data))

logmeup.on = (msg, callback) ->
  logmeup.messages[msg] = callback

###
logmeup.init = (callback) ->
  alert window.location.href
  urlFields = window.location.href.split('log/')
  collection_app = urlFields[1].split('/')
  collection = collection_app[0]
  app = collection_app[1]
###
