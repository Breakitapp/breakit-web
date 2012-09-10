chai = require 'chai'
chai.should()

{User} = require '../app/src/models/userModel'

describe 'User instance', ->
	user = null
	
	it 'Should have a first name, last name, nickname, email, and phone', ->
		user = new User 'fn', 'ln', 'nn', 'em', 'ph'
		user.fName
