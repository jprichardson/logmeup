module.exports = 
  port: 7070
  recordsPerPage: 100
  database:
    development:
      name: 'logmeup'
      host: '127.0.0.1'
      port: 27017
    testing:
      name: 'logmeup_testing'
      host: '127.0.0.1'
      port: 27017
    production:
      name: 'logmeup'
      host: '127.0.0.1'
      port: 27017