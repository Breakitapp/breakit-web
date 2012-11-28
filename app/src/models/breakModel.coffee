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
		
		break_ = new models.Break
			loc						:		{lon: @longitude, lat: @latitude}
			location_name			:		@location_name
			story					:		@story
			headline				:		@headline
			user					:		@user
			points					:		@startingPoints
			startingPoints			:		@startingPoints
			
		break_.upvotes.push @user
		
		userModel.findById @user, (err, author) ->
			if err
				throw err
			else
				break_.usernick = author.nName
		
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
	

#search from breaks
searchBreaks = (x, callback) ->
		console.log x
		models.Break.find().sort({'date': 'descending'}).exec((err, breaks) ->
			#Errorhandling goes here //if err throw err
			breaks_ = breaks
			breaksArr = []
			for b in breaks_
				headline = b.headline.toString().toLowerCase()
				x = x.toLowerCase()
				if headline.indexOf(x) != -1
					breaksArr.push b
			callback null, breaksArr
			return breaksArr
		)
		
		

sortByComments = (callback) ->
	models.Break.find().sort({'date': 'desc'}).exec((err, breaks)->
		breaks_ = breaks
		breaksArr = []
		breaksArrSorted = []
		for b in breaks
			breaksArr.push b
		for b in breaksArr
			countLoops = 0
			wantedBreakPos = 0
			x = 0
			for getNextBreak in breaksArr
				if x < getNextBreak.comments.length
					x = getNextBreak.comments.length
					wantedBreakPos = countLoops
				countLoops += 1
			breaksArrSorted.push breaksArr[wantedBreakPos]
			breaksArr.splice(wantedBreakPos, 1)
		callback null, breaksArrSorted
		return breaksArrSorted
	)
sortByViews = (callback) ->
	models.Break.find().sort({'views': 'descending'}).exec((err, breaks)->
		breaks_ = (b for b in breaks)
		callback null, breaks_
		return breaks_
	)
sortByVotes = (callback) ->
	models.Break.find().sort({'votes': 'descending'}).exec((err, breaks)->
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
							break_.points = break_.startingPoints + 500000 * Math.log (break_.upvotes.length - break_.downvotes.length)
						else if (break_.upvotes.length - break_.downvotes.length) == 0
							break_.points = break_.startingPoints
						else
							break_.points = break_.startingPoints - 500000 * Math.log (break_.downvotes.length - break_.upvotes.length)
				
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
				
del = (breakId, userId, callback) ->
	findById breakId, (err, break_) ->
		if err
			callback err
		else
			if String(break_.user) is String(userId)
				#check if the break is a top break. if so, give the album a new topbreak (or remove the album).
				if break_.top
					albumModel.findById break_.album, (err, album) ->
						if err
							callback err
						else
							albumModel.getBreak album._id, 1, (err, newTop) ->
								
								#Check if the album only contains 1 break
								if String(newTop._id) is String(break_.id)
									album.remove (err) ->
										if err
											callback err
										else
											break_.remove (err) ->
												callback err
								else
									album.topBreak = newTop
									album.save (err) ->
										if err
											callback err
										else
											break_.remove (err) ->
												callback err		
				else	
					break_.remove (err) ->
						callback err
						
				#delete (or rename) the image file. how?
				
			else
				callback 'Invalid user or user not authorized to delete this break.'
				
#modify break?

root = exports ? window
root.Break = Break
root.comment = comment
root.createBreak = createBreak
root.findAll = findAll
root.searchBreaks = searchBreaks
root.sortByComments = sortByComments
root.sortByViews = sortByViews
root.sortByVotes = sortByVotes
root.fbShare = fbShare
root.tweet = tweet
root.findInfinite = findInfinite
root.findById = findById
root.vote = vote
root.del = del
