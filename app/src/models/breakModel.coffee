models = require './mongoModel'

class Break
	constructor: (@id, @longitude, @latitude, @location_name, @user = 'anonymous') ->

	save: (user = @user) ->
		@user = user
		break1 = new models.Break
			id						:		@id
			loc						:		{lon: @longitude, lat: @latitude}
			location_name	:		@location_name
			user					:		@user
		break1.save (err) ->
			if err 
				throw err
			else
				saved = true
				console.log 'saved a new break # #{@id} for #{@user}'

	findAll: (callback) ->

		models.Break.find().sort({'date': 'descending'}).exec((err, breaks) ->
			#Errorhandling goes here //if err throw err
			breaks_ = (b for b in breaks)
			callback 'null', breaks_
			return breaks_
		)

root = exports ? window
root.Break = Break
