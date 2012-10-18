models = require './mongoModel'
albumModel = require './albumModel'
commentModel = require './commentModel'


class Break
	constructor: (@longitude, @latitude, @location_name, @story, @headline, @user = 'anonymous') ->
		console.log Date.now() + ': CREATED A NEW BREAK '+ @headline + ' to ' + @location_name

	saveToDB: (user = @user, callback) ->
		@user = user
		
		#Assign initial points to the new break based on the creation datetime
		epoch = new Date(1970, 1, 1)
		@startingPoints = Date.now() - epoch
						
		break_ = new models.Break
			loc						:		{lon: @longitude, lat: @latitude}
			location_name		:		@location_name
			story				:		@story
			headline			:		@headline
			user					:	@user
			points					:	@startingPoints
			startingPoints			:	@startingPoints
			
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
			
			#updating the top break of the album if this break is it
			if break_.top
				albumModel.updateTop break_.album, break_, (err) ->
					if err
						throw err
					
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

#finds an x amout of breaks in the vicinity. NOT USED?
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

#NOT USED?
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

vote = (breakId, direction, callback) ->
	
	if (direction isnt 'up') and (direction isnt 'down')
		err = new Error 'BREAK: invalid direction'
		callback err, null
	
	#Vote is valid
	else
		#Finding the break
		findById breakId, (err, break_) ->
			if err
				console.log 'BREAK: failed to find break to be voted'
				callback err, null
			else
				#Finding the album (for checking top break points later)
				albumModel.findById break_.album, (err, a) ->
					if err
						console.log 'BREAK: failed to find album of the break to be voted'
						callback err, null
					else
			
						#Voting increments the up/down votes of the breaks.
						if direction is 'up'
							break_.upvotes++
						if direction is 'down'
							break_.downvotes++
				
						#calculating new points
						if (break_.upvotes - break_.downvotes) > 0
							break_.points = break_.startingPoints + 1000000 * Math.log (break_.upvotes - break_.downvotes)
						else if (break_.upvotes - break_.downvotes) == 0
							break_.points = break_.startingPoints
						else
							break_.points = break_.startingPoints - 1000000 * Math.log (break_.downvotes - break_.upvotes)
				
						if break_.top or (break_.points > a.topBreak.points)
							break_.top = true
							albumModel.updateTop break_.album, break_, (err) ->
								if err
									throw err
				
						console.log break_.points
						break_.save (err) ->
							if err
								console.log 'BREAK: Break save failed after vote'
								callback err, null
							else
								console.log 'BREAK: Vote successful: ' + break_._id
								callback null, (break_.upvotes - break_.downvotes)
				


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
			now = Date.now()
			
			diff = created - epoch
			diff2 = now - epoch
			
			#elapsed = created - epoch
			
			#points = X * log(break_.score) + Y*elapsed
			#tjsp
			
			console.log epoch
			console.log created
			console.log now
			console.log diff
			console.log diff2
			
			console.log 'BREAK: calculated points for break ' + breakId + ' successfully'
			callback null, points
			###

root = exports ? window
root.Break = Break
root.comment = comment
root.createBreak = createBreak
root.findAll = findAll
root.findNear = findNear
root.findInfinite = findInfinite
root.findById = findById
root.vote = vote
#root.points = points
