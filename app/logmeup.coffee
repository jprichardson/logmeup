express = require('express')
fs = require('fs')
path = require('path')
database = require('./database')
#assets = require('connect-assets')

logmeup = module.exports = {}
app = module.exports.app = express.createServer();
io = require('socket.io').listen(app)
io.set('log level',1)
routes = require('./routes')


app.configure ->
  app.set('views', __dirname + '/views')
  app.set("view options", {layout: true})
  app.set('view engine', 'jade')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))

  ###
  app.register '.html', ->
    compile: (str, options) ->
      (locals) ->
        str
  ###

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'testing', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
  app.all '/testing/:file', (req, res) ->
    fs.readFile path.join(__dirname,"../test/browser/#{req.params.file}"), (err,data) ->
      file = req.params.file
      console.log file
      if file.endsWith('.html')
        res.header("Content-Type", "text/html")
      else if file.endsWith('.js')
        res.header("Content-Type", "application/javascript")
      else if file.endsWith('.coffee')
        res.header("Content-Type", "text/coffeescript");
      
      if data?
        res.send data.toString()
      else # file not found
        res.send 'File not found.'

app.configure 'production', ->
  app.use(express.errorHandler())

app.get('/', routes.index)
app.delete('/log/:org/:app', routes.delete)
app.put('/log/:org/:app', routes.create) 
app.post('/log/:org/:app', routes.store)
app.get('/log/:org/:app', routes.show)

app.get('/log/:org/:app/data.json', routes.data)

logmeup.init = (params = {}, callback) ->
  config = params.config

  logmeup.env = app.settings.env

  database.connect config: config.database[logmeup.env], (err,db) ->
    callback(err) if err?
    routes.configure(db, io, config.recordsPerPage)

    io.sockets.on 'connection', (socket) ->
      console.log  (new Date()).toString() + ': client connected'
      #socket.emit('news', {data: 'hello from server socket'})

      #socket.on 'client', (data) ->
      #  console.log 'got from client: ' + data
      #  socket.emit('news', 'loud and clear buddy')
    callback(null)