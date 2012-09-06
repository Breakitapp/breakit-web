chai = require 'chai'
chai.should()

{Break} = require '../app/src/models/breakModel'

describe 'Break instance', ->
	break1 = null

	it 'Should have a name', ->
		break1 = new Break 'An anonymous break'
		break1.name.should.equal 'An anonymous break'
