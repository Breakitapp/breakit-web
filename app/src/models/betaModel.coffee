#This is only for receiving beta registrations

models = require './mongoModel'

class BetaUser
	constructor: (@email, @phone) ->
						
	save: (callback) ->
		user = new models.BetaUser
			email : @email
			phone : @phone
		user.save (err) ->
			if err
				console.log err
				callback err, null
			else
				console.log 'USER: Saved a new user: ' + user.id
				callback null, user
				
root = exports ? window
root.BetaUser = BetaUser