models = require './mongoModel'

class Break
	constructor: (@longitude, @latitude, @location_name, @story, @headline, @user = 'anonymous') ->

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
	console.log 'CREATEBREAK : ' + data
	break_ = new Break parseFloat data.longitude, parseFloat data.latitude, data.location_name, data.story, data.headline
	break_.save(data.user, callback)


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
	console.log 'FIND NEAR lon: ' + longitude + ' lat: ' + latitude 
	breaks = []
	models.Break.db.db.executeDbCommand {
		geoNear: 'breaks' 
		near : [longitude, latitude] 
		spherical : true
		}, (err, docs) ->
			if err
				throw err
			console.log docs
			if docs.documents[0].results
				b = docs.documents[0].results
				for object in b
					found_break = object.obj
					found_break.dis = object.dis
					breaks.push found_break
					#Slice the array to contain only 10/page and return the 10 breaks
					#breaks = breaks[page*10..(page+1)*10]
			callback null, breaks
	return breaks

findInfinite = (page, callback) ->
	models.Break.find().skip(10*(page-1)).limit(10).exec((err, breaks) ->
		breaks_ = (b for b in breaks)
		callback null, breaks_
		return breaks_
	)

root = exports ? window
root.Break = Break
root.createBreak = createBreak
root.findAll = findAll
root.findNear = findNear
root.findInfinite = findInfinite
