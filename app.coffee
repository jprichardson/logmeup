
exec = require('child_process').exec
program = require('commander');

program.version('0.0.4')
  .option('-f, --config [value]', 'The config file to use. Default file is lib/node_modules/logmeup-server/config/config.coffee')
  .parse(process.argv);

main = ->
  config = null
  if program.config?
    config = require(program.config)
  else
    config = require('./config/config')

  if typeof(process.env['NODE_ENV']) is 'undefined'
    process.env['NODE_ENV'] = config.defaultenv

  logmeup = require('./app/logmeup') #REFACTOR and move

  logmeup.init config: config, (err) ->
    if err? then console.log err.message; process.exit()

    logmeup.app.listen(config.port)
    console.log("Server listening on port %d in %s mode", logmeup.app.address().port, logmeup.app.settings.env)

    if logmeup.env is 'testing'
      addrInfo = logmeup.app.address()
      exec("Open http://#{addrInfo.address}:#{addrInfo.port}/testing/app.test.html",->)

main()
