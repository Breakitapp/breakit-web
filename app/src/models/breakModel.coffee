models = require './mongoModel'
albumModel = require './albumModel'

class Break
	constructor: (@longitude, @latitude, @location_name, @story, @headline, @user = 'anonymous') ->
		console.log 'CREATED A NEW BREAK'+@headline+' to ' + @location_name

	save: (user = @user, callback) ->
		@user = user
		break_ = new models.Break
			loc						:		{lon: @longitude, lat: @latitude}
			location_name	:		@location_name
			story					:		@story
			headline			:		@headline
			user					:		@user
		that = @
		break_.save (err) ->
			if err 
				throw err
			else
				saved = true
				console.log 'BREAK: saved a new break ' + that.story + ' for ' + that.user.nName
				callback null, break_


createBreak = (data, callback) ->
	break_ = new Break data.longitude, data.latitude, data.location_name, data.story, data.headline
	break_.save(data.user, callback)
	albumModel.addBreak break_.location_name, break_


#find all the breaks
findAll = (callback) ->
		models.Break.find().sort({'date': 'descending'}).exec((err, breaks) ->
			#Errorhandling goes here //if err throw err
			breaks_ = (b for b in breaks)
			callback null, breaks_
			return breaks_
		)

#finds an x amout of breaks in the vicinity
findNear = (longitude, latitude, page, callback) ->
	breaks = []
	models.Break.db.db.executeDbCommand {
		geoNear: 'breaks' 
		near : [longitude, latitude] 
		spherical : true
		}, (err, docs) ->
			if err
				throw err
			b = docs.documents[0].results
			if b[0] and b[page*10]
				i = 0
				while b[page*10+i] and i < 10
					object = b[page*10+i]
					found_break = object.obj
					found_break.dis = object.dis
					breaks.push found_break
					i++
			#TODO handling of the last breaks modulus
			callback null, breaks
	return breaks

findInfinite = (page, callback) ->
	models.Break.find().skip(10*(page-1)).limit(10).exec((err, breaks) ->
		breaks_ = (b for b in breaks)
		callback null, breaks_
		return breaks_
	)
	
findById = (id, callback) ->
	models.Break.findById(id).exec((err, breaks) ->
		callback err, breaks
	)

root = exports ? window
root.Break = Break
root.createBreak = createBreak
root.findAll = findAll
root.findNear = findNear
root.findInfinite = findInfinite
root.findById = findById
