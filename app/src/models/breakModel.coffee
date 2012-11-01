models = require './mongoModel'
albumModel = require './albumModel'
commentModel = require './commentModel'
userModel = require './userModel'

class Break
	constructor: (@longitude, @latitude, @location_name, @story, @headline, @user) ->
		console.log Date.now() + ': CREATED A NEW BREAK '+ @headline + ' to ' + @location_name

	saveToDB: (callback) ->
		
		#Assign initial points to the new break based on the creation datetime
		epoch = new Date(1970, 1, 1)
		@startingPoints = Date.now() - epoch
		
		userModel.findById @user, (err, author) ->
			if err
				throw err
			else
				
		
				break_ = new models.Break
					loc						:		{lon: @longitude, lat: @latitude}
					location_name			:		@location_name
					story					:		@story
					headline				:		@headline
					user					:		@user
					usernick				:		author.nName
					points					:		@startingPoints
					startingPoints			:		@startingPoints
			
				break_.upvotes.push @user
			
				break_.save (err) ->
					if err 
						console.log 'BREAK: Break save failed'
						throw err
					else
					console.log 'BREAK: Break saved successfully @ ' + break_.loc.lon + ', ' + break_.loc.lat
					callback null, break_

createBreak = (longitude, latitude, location_name, story, headline, userId, callback) ->
	break_ = new Break longitude, latitude, location_name, story, headline, userId
	break_.saveToDB (err, b) ->
		callback err, b
	
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
					
#Saves the userId that has shared a break in facebook
fbShare = (breakId, userId, callback) ->
	findById breakId, (err, break_) ->
		if err
			console.log 'BREAK: failed to find break to be shared in Facebook. Id: ' + breakId
			callback err
		else
			break_.fbShares.push userId
			break_.save (err) ->
				if err
					callback err
				else
					console.log 'Saved a Break after a new Facebook share was added.'
					callback null

#Saves the userId that has tweeted a break
tweet = (breakId, userId, callback) ->
	findById breakId, (err, break_) ->
		if err
			console.log 'BREAK: failed to find break to be tweeted. Id: ' + breakId
			callback err
		else
			break_.tweets.push userId
			break_.save (err) ->
				if err
					callback err
				else
					console.log 'Saved a Break after a new Tweet was added.'
					callback null

#find all the breaks
findAll = (callback) ->
		models.Break.find().sort({'date': 'descending'}).exec((err, breaks) ->
			#Errorhandling goes here //if err throw err
			breaks_ = (b for b in breaks)
			callback null, breaks_
			return breaks_
		)

#finds an x amout of breaks in the vicinity. NOT USED?

###
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
###

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

vote = (breakId, userId, direction, callback) ->
	
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
							break_.upvotes.push userId
						if direction is 'down'
							break_.downvotes.push userId
				
						#calculating new points
						if (break_.upvotes.length - break_.downvotes.length) > 0
							break_.points = break_.startingPoints + 1000000 * Math.log (break_.upvotes.length - break_.downvotes.length)
						else if (break_.upvotes.length - break_.downvotes.length) == 0
							break_.points = break_.startingPoints
						else
							break_.points = break_.startingPoints - 1000000 * Math.log (break_.downvotes.length - break_.upvotes.length)
				
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
								callback null, break_
				

root = exports ? window
root.Break = Break
root.comment = comment
root.createBreak = createBreak
root.findAll = findAll
root.fbShare = fbShare
root.tweet = tweet
root.findInfinite = findInfinite
root.findById = findById
root.vote = vote
