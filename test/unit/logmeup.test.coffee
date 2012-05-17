require('testutil')
logmeup = require('../../app/logmeup')


describe 'logmeup', ->
  describe '+ env', ->
    it 'should return the string environment set from NODE_ENV on the command line', ->
      T logmeup.env is 'testing'


  
    

          
