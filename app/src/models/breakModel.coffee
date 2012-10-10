models = require './mongoModel'
albumModel = require './albumModel'
commentModel = require './commentModel'

class Break
	constructor: (@longitude, @latitude, @location_name, @story, @headline, @user = 'anonymous') ->
		@points = 
		console.log Date.now() + ': CREATED A NEW BREAK '+ @headline + ' to ' + @location_name

	saveToDB: (user = @user, callback) ->
		@user = user
		@points = 0
				
		break_ = new models.Break
			loc						:		{lon: @longitude, lat: @latitude}
			location_name		:		@location_name
			story					:		@story
			headline			:		@headline
			user					:		@user
			score					:		0
			points					:	@points
			
		that = @
		break_.save (err) ->
			if err 
				console.log 'BREAK: Break save failed'
				throw err
			else
				console.log 'BREAK: Break saved successfully @ ' + break_.loc.lon + ', ' + break_.loc.lat
				callback null, break_
				
	update: (callback) ->
		@points = @points + @score * 1000000
		break_.save (err) ->
			if err 
				console.log 'BREAK: Break save failed'
				throw err
			else
				console.log 'BREAK: Break saved successfully @ ' + break_.loc.lon + ', ' + break_.loc.lat
				callback null, break_
		

createBreak = (data, callback) ->
	break_ = new Break data.longitude, data.latitude, data.location_name, data.story, data.headline
	break_.saveToDB data.user, (err, b) ->
			callback err, b

### probably useless
addAlbum = (album, breakId, callback) ->
	findById breakId, (err, break_) ->
		if err
			console.log 'BREAK: failed to find break to be assigned an album. Id: ' + breakId
			callback err, null
		else
			break_.album = album
			break_.save (err) ->
				if err
					console.log 'BREAK: Break save failed after new album'
					callback err
				else
					console.log 'BREAK: Album added successfully to break: ' + break_._id
					callback null
###	
	
	
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
	models.Break.findById(id).exec((err, break_) ->
		callback err, break_
	)
	
upvote = (breakId, callback) ->
	findById breakId, (err, break_) ->
		if err
			console.log 'BREAK: failed to find break to be upvoted'
			callback err, null
		else
			break_.score++
			break_.update (err) ->
				if err
					console.log 'BREAK: Break update failed after upvote'
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
			break_.update (err) ->
				if err
					console.log 'BREAK: Break update failed after downvote'
					callback err, null
				else
					console.log 'BREAK: Downvote successful: ' + break_._id
					callback null, break_.score	

#first draft of points calculation
#only for testing
###
points = (breakId, callback) ->
	findById breakId, (err, break_) ->
		if err
			console.log 'BREAK: failed to find break for points calculation'
			callback err, null
		else
			points = 0
			
			#these need to be same format first
			epoch = new Date(1970, 1, 1) 
			created = break_.date # assume this is in seconds now
			
			#elapsed = created - epoch
			
			#points = X * log(break_.score) + Y*elapsed
			#tjsp
			
			console.log epoch
			console.log created
			
			console.log 'BREAK: calculated points for break ' + breakId + ' successfully'
			callback null, points
			###

root = exports ? window
root.Break = Break
root.comment = comment
root.createBreak = createBreak
#root.addAlbum = addAlbum
root.findAll = findAll
root.findNear = findNear
root.findInfinite = findInfinite
root.findById = findById
root.upvote = upvote
root.downvote = downvote
#root.points = points
