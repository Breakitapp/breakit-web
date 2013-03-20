models = require './mongoModel'
albumModel = require './albumModel'
commentModel = require './commentModel'
userModel = require './userModel'
notificationsModel = require './notificationsModel'
_ = require 'underscore'


class Break
	constructor: (@longitude, @latitude, @placeName, @placeId, @story, @headline, @user) ->
		console.log Date.now() + ': CREATED A NEW BREAK '+ @headline + ' to ' + @placeName

	saveToDB: (callback) ->
		#Assign initial points to the new break based on the creation datetime
		epoch = new Date(1970, 1, 1)
		@startingPoints = Date.now() - epoch
		
		break_ = new models.Break
			loc							:		{lon: @longitude, lat: @latitude}
			placeName				:		@placeName
			placeId 				:		@placeId
			story						:		@story
			headline				:		@headline
			user						:		@user
			points					:		@startingPoints
			startingPoints	:		@startingPoints
			
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
	console.log 'NEW COMMENT OCCURRING'
	console.log 'comment: '+comment
	console.log 'breakId: '+breakId
	findById breakId, (err, break_) ->
		if err 
			console.log 'BREAK: failed to find break to be commented. Id: ' + breakId
			callback err, null
		else
			sentUsers = []
			for breakComment in break_.comments
				console.log 'in for'
				if breakComment.user isnt comment.user
					console.log 'breakComment.user: '+String(breakComment.user)
					if breakComment.user not in sentUsers and breakComment.user isnt break_.user and (String(breakComment.user) isnt '5110eff913e66edb527cb501') and (String(breakComment.user) isnt '50a369413268496061000002')
						console.log 'SENDING NOTIFICATIONS OF COMMENT'
						console.log 'SENDING TO userId: '+breakComment.user
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
			#MARKO: These breaks_ and breaks seem to be same. Look into this when refactoring
			callback null, breaks_
			return breaks_
		)
		
#Similar to AlbumModel getFeed and will replace it in the next iteration.
getFeed = (longitude, latitude, page, shownBreaks, callback) ->
	
	# get closest X elements, depending on which page the user is in. They are the first as the array is sorted by location
	range = 500+100*page
	#Would like to have a more dynamic way to take the distance into account here... -E
	
	breaks = []
	#This is the geonear mongoose function, that searches for locationbased nodes in db
	#First it searches for 'range' amount of breaks.
	models.Break.db.db.executeDbCommand {
		geoNear: 'breaks'
		near : [longitude, latitude]
		num : range
		spherical : true
		}, (err, docs) ->
			
			#console.log 'inside dbcommand'
			
			if err
				throw err
			else
				if docs.documents[0].results
					b = docs.documents[0].results
					i = 0
					
					console.log 'b.length ' + b.length
					
					while i < b.length
						foundBreak = b[i].obj
						foundBreak.dis = b[i].dis
						
						#Now the shown breaks are excluded from results
						alreadyShown = false
						
						if shownBreaks
							
							console.log 'shownbreaks exist'
							
							j = 0
							while j < shownBreaks.length
								
								#Checking if the break has been shown already or if the album has been shown already
								if (String(shownBreaks[j]) is String(foundBreak._id)) or (String(shownBreaks[j]) is String(foundBreak.album))
									alreadyShown = true
									break
								j++
								
						
						if not alreadyShown #Break hasn't been shown before
							
							#console.log 'not shown'
							
							#This code ensures that only the best break of an album is included
							if foundBreak.album != null
								
								#console.log 'breaks album not null'
								
								albumAdded = false
								k = 0
								while k < breaks.length
									if String(foundBreak.album) is String(breaks[k].album)
										albumAdded = true
										if foundBreak.points > breaks[k].points
											breaks[k] = foundBreak
										else
											break
									k++
								
								if not albumAdded
									breaks.push foundBreak
									#add view to break when feed is loaded
									addView foundBreak._id, (err, foundBreak) ->
											#console.log 'break id for foundBreak is: ' + foundBreak._id
										if err
											console.log 'added view fail'
										else
											#console.log 'added view succcess'
							#This break hasn't been shown before
							else
								breaks.push foundBreak
								#Add view to break when feed is loaded
								addView foundBreak._id, (err, foundBreak) ->
									if err
										console.log 'added view fail'
									else
										#console.log 'added view succcess'
								
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
	
#Millan webinterfacea varten
findMediaRows = (pageNumber,sortPage, callback) ->
	breaksPerPage = 12
	models.Break.find().sort({'date': 'descending'}).skip(pageNumber*breaksPerPage).limit(breaksPerPage).exec((err, breaks) ->
		console.log 'sortPage: ' + sortPage
		breaks_ = (b for b in breaks)
		models.Break.count().exec((err, count) ->
			callback null, breaks_, count, sortPage
		)
	)

#Millan
#search from breaks
searchBreaks = (searchWord, pageNumber, sortPage, callback) ->
		console.log 'entering search Breaks'
		breaksPerPage = 12
		breaksToSkip = pageNumber*breaksPerPage
		console.log 'searchword: ' + searchWord
		#checks if the search value matches the search word. If it matches the break is "found"
		models.Break.find({'headline':$regex:searchWord,$options: 'i'}).sort({'date': 'descending'}).skip(pageNumber*breaksPerPage).limit(breaksPerPage).exec((err, breaks) ->
			console.log 'find function'
			breaks_ = (b for b in breaks)
			#counts the breaks that include the searchword in their headlines
			models.Break.count({'headline':$regex:searchWord,$options: 'i'}).exec((err, count) ->
				console.log('count in search: ' + count)
				callback null, breaks_, count, sortPage, searchWord
			)
		)
		

#Millan
sortByComments = (pageNumber,sortPage, callback) ->
	models.Break.find().sort({'date': 'desc'}).exec((err, breaks)->
		console.log 'entering sortByComments'
		breaks_ = breaks
		breaksArr = []
		breaksArrSorted = []
		breaksPerPage = 12
		checkIfSkip = 0
		breaksToSkip = pageNumber*breaksPerPage
		console.log 'breaks to skip: ' + breaksToSkip
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
			if checkIfSkip >= breaksToSkip
				breaksArrSorted.push breaksArr[wantedBreakPos]
				if breaksArrSorted.length is breaksPerPage
					break
			else
				checkIfSkip += 1
			breaksArr.splice(wantedBreakPos, 1)
		models.Break.count().exec((err, count) ->
			callback null, breaksArrSorted, count, sortPage
		)
	)

#Millan
sortByViews = (pageNumber,sortPage, callback) ->
	breaksPerPage = 12
	models.Break.find().sort({'views': 'descending'}).skip(pageNumber*breaksPerPage).limit(breaksPerPage).exec((err, breaks)->
		breaks_ = (b for b in breaks)
		models.Break.count().exec((err, count) ->
			callback null, breaks_, count, sortPage
		)
	)
	
#Millan
sortByVotes = (pageNumber,sortPage, callback) ->
	models.Break.find().sort({'date': 'descending'}).exec((err, breaks)->
		breaksPerPage = 12
		breaks_ = breaks
		breaksArr = []
		breaksArrSorted = []
		positionLimits = pageNumber+1 *breaksPerPage
		breaksToSkip = pageNumber*breaksPerPage
		checkIfSkip = 0
		console.log 'breaks to skip: ' + breaksToSkip
		for b in breaks
			breaksArr.push b
		for b in breaksArr
			countLoops = 0
			wantedBreakPos = 0
			x = -10000000
			for getNextBreak in breaksArr
				score = getNextBreak.upvotes.length - getNextBreak.downvotes.length
				console.log 'x is: ' + x + ' score is: ' + score
				if x < score
					x = score
					wantedBreakPos = countLoops
				countLoops += 1
			if checkIfSkip >= breaksToSkip
				console.log 'chosen score: ' + x
				console.log '****'
				breaksArrSorted.push breaksArr[wantedBreakPos]
				if breaksArrSorted.length is breaksPerPage
					break
			else
				checkIfSkip += 1
			breaksArr.splice(wantedBreakPos, 1)
		models.Break.count().exec((err, count) ->
			callback null, breaksArrSorted, count, sortPage
		)
	)
	
findById = (id, callback) ->
	models.Break.findById(id).exec((err, break_) ->
		callback err, break_
	)

#find break and add one to view, not used atm in the app (only in media interface)
addView = (id, callback) ->
	#models.Break.findById(id).exec((err, break_) ->
	query ={'_id':id}
	console.log 'id: '+id
	console.log 'query: '+query
	models.Break.findOneAndUpdate(query,{$inc:{'views': 1}}).exec((err, break_)->
		if err
			console.log 'break: '+break_
			console.log 'something went wrong in find and update'
		else
			#console.log 'views updated'
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
							break_.points = break_.startingPoints + 2500000 * Math.log (break_.upvotes.length - break_.downvotes.length)
						else if (break_.upvotes.length - break_.downvotes.length) == 0
							break_.points = break_.startingPoints
						else
							break_.points = break_.startingPoints - 2500000 * Math.log (break_.downvotes.length - break_.upvotes.length)
				
						console.log break_.points
						break_.save (err) ->
							if err
								console.log 'BREAK: Break save failed after vote'
								callback err, null
							else
								console.log 'BREAK: Vote successful: ' + break_._id
								callback null, break_

del = (breakId, callback) ->
	findById breakId, (err, break_) ->
		if err
			callback err
		else
			#if String(break_.user) is String(userId)
			break_.remove (err) ->
				console.log 'Break deleted: ' + breakId
				callback err
						
				#delete (or rename) the image file. how?
				
root = exports ? window
root.Break = Break
root.comment = comment
root.createBreak = createBreak
root.getFeed = getFeed
root.findAll = findAll

#media interface stuff
root.searchBreaks = searchBreaks
root.sortByComments = sortByComments
root.sortByViews = sortByViews
root.sortByVotes = sortByVotes
root.findMediaRows = findMediaRows

root.addView = addView
root.fbShare = fbShare
root.tweet = tweet
root.findById = findById
root.vote = vote
root.del = del
