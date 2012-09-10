chai = require 'chai'
chai.should()
chai.expect()

{Break} = require '../app/src/models/breakModel'

describe 'Break instance', ->
	break1 = null

	it 'Should have an id', ->
		break1 = new Break 1, 65, 65, 'venture garage'
		break1.id.should.equal 1

	it 'should be able to be saved to db', ->
		break1.save().should.exist

	it 'should have initial score of 1', ->
		break1.score.should.equal '1'

	it 'Should be able to be upvoted', ->
		break1.upVote()

	it 'Should be able to be downvoted', ->
		break1.downVote()

