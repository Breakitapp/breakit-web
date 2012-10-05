models = require './mongoModel'
albumModel = require './albumModel'
commentModel = require './commentModel'

class Break
	constructor: (@longitude, @latitude, @location_name, @story, @headline, @user = 'anonymous') ->
		console.log Date.now() + ': CREATED A NEW BREAK '+ @headline + ' to ' + @location_name

	save: (user = @user, callback) ->
		@user = user
		break_ = new models.Break
			loc						:		{lon: @longitude, lat: @latitude}
			location_name	:		@location_name
			story					:		@story
			headline			:		@headline
			user					:		@user
			score					:		1
		that = @
		break_.save (err) ->
			if err 
				console.log 'BREAK: Break save failed'
				throw err
			else
				console.log 'BREAK: Break saved successfully.'
				callback null, break_

createBreak = (data, callback) ->
	break_ = new Break data.longitude, data.latitude, data.location_name, data.story, data.headline
	break_.save(data.user, callback)
	
comment = (comment, breakId, callback) ->
	findById breakId, (err, break_) ->
		if err
			console.log 'BREAK: failed to find break to be commented. Id: ' + breakId
			callback err, null
		else
			break_.comments.push comment
			break_.save (err) ->
				if err
					console.log 'BREAK: Break save failed after new comment'
					callback err, null
				else
					console.log 'BREAK: New comment added successfully to break: ' + break_._id
					callback null, break_.comments.length
	
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
			if b[0]
				i = 0
				while b[page*10+i] and i < 10
					object = b[page*10+i]
					found_break = object.obj
					found_break.dis = object.dis
					breaks.push found_break
					i++
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
	
upvote = (breakId, callback) ->
	findById breakId, (err, break_) ->
		if err
			console.log 'BREAK: failed to find break to be upvoted'
			callback err, null
		else
			break_.score++
			break_.save (err) ->
				if err
					console.log 'BREAK: Break save failed after upvote'
					callback err, null
				else
					console.log 'BREAK: Upvote successful: ' + break_._id
					callback null, break_.score
					
downvote = (breakId, callback) ->
	findById breakId, (err, break_) ->
		if err
			console.log 'BREAK: failed to find break to be upvoted'
			callback err, null
		else
			break_.score--
			break_.save (err) ->
				if err
					console.log 'BREAK: Break save failed after downvote'
					callback err, null
				else
					console.log 'BREAK: Downvote successful: ' + break_._id
					callback null, break_.score	

root = exports ? window
root.Break = Break
root.comment = comment
root.createBreak = createBreak
root.findAll = findAll
root.findNear = findNear
root.findInfinite = findInfinite
root.findById = findById
root.upvote = upvote
root.downvote = downvote
