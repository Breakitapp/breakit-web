models = require './mongoModel'

class Break
	constructor: (@id, @longitude, @latitude, @location_name, @story, @headline, @user = 'anonymous') ->

	save: (user = @user) ->
		@user = user
		break1 = new models.Break
			id						:		@id
			loc						:		{lon: @longitude, lat: @latitude}
			location_name	:		@location_name
			story					:		@story
			headline			:		@headline
			user					:		@user
		that = @
		break1.save (err) ->
			if err 
				throw err
			else
				saved = true
				that._id = break1._id
				console.log 'BREAK: saved a new break #' + that.id + ' for ' + that.user.nName


#find all the breaks
findAll = (callback) ->

		models.Break.find().sort({'date': 'descending'}).exec((err, breaks) ->
			#Errorhandling goes here //if err throw err
			breaks_ = (b for b in breaks)
			callback 'null', breaks_
			return breaks_
		)

#finds an x amout of breaks in the vicinity
findNear = (number, longitude, latitude,  callback) ->
	breaks = []
	models.Break.db.db.executeDbCommand {
		geoNear: 'breaks' 
		near : [longitude, latitude] 
		spherical : true
		}, (err, docs) ->
			#the results are in format {dist: x, obj: {}}, needs to be put in one object only
			b = docs.documents[0].results
			for object in b
				break_tmp = object.obj
				break_tmp.dis = object.dis
				breaks.push break_tmp
			callback null, breaks
	return breaks

root = exports ? window
root.Break = Break
root.findAll = findAll
root.findNear = findNear
