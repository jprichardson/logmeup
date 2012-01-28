logmeup = require('../../app/logmeup')
assert = require('assert')

T = (v) -> assert(v)
F = (v) -> assert(!v)

describe 'logmeup', ->
  describe '+ env', ->
    it 'should return the string environment set from NODE_ENV on the command line', ->
      T logmeup.env is 'testing'

  
    

          
