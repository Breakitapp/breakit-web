chai = require 'chai'
chai.should()

{Break} = require '../app/src/models/breakModel'

describe 'Break instance', ->
	break1 = null

	it 'Should have a name, location and location name', ->
		break1 = new Break 'An anonymous break', [65,64], 'venture garage'
		break1.name.should.equal 'An anonymous break'
		break1.loc.should.equal [65,64]
		break1.location_name.should.equal 'venture garage'
