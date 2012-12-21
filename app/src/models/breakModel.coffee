models = require './mongoModel'
albumModel = require './albumModel'
commentModel = require './commentModel'
userModel = require './userModel'
notificationsModel = require './notificationsModel'

class Break
	constructor: (@longitude, @latitude, @placeName, @placeId, @story, @headline, @user) ->
		console.log Date.now() + ': CREATED A NEW BREAK '+ @headline + ' to ' + @placeName

	saveToDB: (callback) ->
		
		#Assign initial points to the new break based on the creation datetime
		epoch = new Date(1970, 1, 1)
		@startingPoints = Date.now() - epoch
		
		break_ = new models.Break
			loc						:		{lon: @longitude, lat: @latitude}
			placeName				:		@placeName
			placeId 				:		@placeId
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

createBreak = (longitude, latitude, placeName, placeId, story, headline, userId, callback) ->
	
	break_ = new Break longitude, latitude, placeName, placeId, story, headline, userId
	break_.saveToDB (err, b) ->
		callback err, b
	
comment = (comment, breakId, callback) ->
	findById breakId, (err, break_) ->
		if err
			console.log 'BREAK: failed to find break to be commented. Id: ' + breakId
			callback err, null
		else
			sentUsers = []
			for breakComment in break_.comments
				console.log 'in for'
				if breakComment.user isnt comment.user 
					if breakComment.user not in sentUsers
						sentUsers.push breakComment.user
						type = 'NO_OWNER'
						notificationsModel.createNotification comment.usernick, breakComment.user, comment.comment, breakId, type, (err)->
							if err
								console.log 'in callback err'
								callback err, null
							else
								console.log 'in callback success'
			break_.comments.push comment
			console.log 'breakId: '+breakId
			if comment.user isnt break_.user
				type = 'OWNER'
				notificationsModel.createNotification comment.usernick, break_.user, comment.comment, breakId, type, (err)->
					if err
						console.log 'in callback err'
						callback err, null
					else
						console.log 'in callback success'
				
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
			console.log 'breaks_[0]:'+breaks_[0]
			console.log 'breaks[0]:'+breaks[0]
			#MARKO: These breaks_ and breaks seem to be same. Look into this when refactoring
			callback null, breaks_
			return breaks_
		)
		
#Similar to AlbumModel getFeed and will replace it in the next iteration.
getFeed = (longitude, latitude, page, shownBreaks, callback) ->
	
	# get closest X elements, depending on which page the user is in. They are the first as the array is sorted by location
	range = 500+100*page
	#Would like to have a more dynamic way to take the distance into account here... -E
	
	albums = []
	#This is the geonear mongoose function, that searches for locationbased nodes in db
	#First it searches for 'range' amount of breaks.
	models.Break.db.db.executeDbCommand {
		geoNear: 'breaks'
		near : [longitude, latitude]
		num : range
		spherical : true
		}, (err, docs) ->
			if err
				throw err
			else
				if docs.documents[0].results
					b = docs.documents[0].results
					i = 0
					while i < b.length
						foundBreak = b[i].obj
						foundBreak.dis = b[i].dis
						
						#Now the shown breaks are excluded from results
						alreadyShown = false
						
						if shownBreaks
							j = 0
							while j < shownBreaks.length
								
								#Checking if the break has been shown already
								#Checking if the album has been shown already...? -> Client needs to add the album id in the shown list.
								if (String(shownBreaks[j]) is String(foundBreak._id)) or (String(shownBreaks[j]) is String(foundBreak.album))
									alreadyShown = true
									break
								j++
						if not alreadyShown
							
							#This code ensures that only the best break of an album is included
							if foundBreak.album != null
								k = 0
								while k < breaks.length
									if String(foundBreak.album) is String(breaks[k].album)
										if foundBreak.points > breaks[k].points
											breaks[k] = foundBreak
										else
											break
								
							#This break hasn't been shown before
							else
								breaks.push foundBreak
						i++
					
					console.log 'nr of breaks: ' + breaks.length
					
					#Then the array is sorted based on points
					sorted = _.sortBy breaks, (break_) ->
						
						#20000000000 multiplier should mean that 100m distance weighs about the same as 1 vote or 200 seconds.
						return Number(-(break_.points - break_.dis*20000000000))

					#And last the first X breaks are sent to the client
					best = _.first(sorted, 50)
					callback null, best
			
	return breaks
	
#search from breaks
#Should just look for the headline in the initial query.
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
		
		
#Why sort by date? Multiple arrays of the same stuff...
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
	models.Break.find().sort({'date': 'descending'}).exec((err, breaks)->
		breaks_ = breaks
		breaksArr = []
		breaksArrSorted = []
		for b in breaks
			breaksArr.push b
		for b in breaksArr
			countLoops = 0
			wantedBreakPos = 0
			x = -10000
			for getNextBreak in breaksArr
				score = getNextBreak.upvotes.length - getNextBreak.downvotes.length
				if x < score
					x = score
					wantedBreakPos = countLoops

				countLoops += 1
			breaksArrSorted.push breaksArr[wantedBreakPos]
			breaksArr.splice(wantedBreakPos, 1)
		callback null, breaksArrSorted
		return breaksArrSorted
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

#find break and add one to view
findAndModify = (id, callback) ->
	#models.Break.findById(id).exec((err, break_) ->
	query ={'_id':id}
	models.Break.findOneAndUpdate(query,{$inc:{'views': 1}}).exec((err, break_)->
		if err
			console.log 'something went wrong'
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
				
						###
						if break_.top or (break_.points > a.topBreak.points)
							break_.top = true
							albumModel.updateTop break_.album, break_, (err) ->
								if err
									throw err
						###
				
						console.log break_.points
						break_.save (err) ->
							if err
								console.log 'BREAK: Break save failed after vote'
								callback err, null
							else
								console.log 'BREAK: Vote successful: ' + break_._id
								callback null, break_

#Needs to be updated
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
root.getFeed = getFeed
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
root.findAndModify = findAndModify
