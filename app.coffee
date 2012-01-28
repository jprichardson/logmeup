config = require('./config/config')
logmeup = require('./app/logmeup')
exec = require('child_process').exec

#logmeup.env = 'production' #by default, it's development

logmeup.init config: config, (err) ->
  if err? then console.log err.message; process.exit()

  logmeup.app.listen(config.port)
  console.log("Server listening on port %d in %s mode", logmeup.app.address().port, logmeup.app.settings.env)

  if logmeup.env is 'testing'
    addrInfo = logmeup.app.address()
    exec("Open http://#{addrInfo.address}:#{addrInfo.port}/testing/app.test.html",->)