###
# Breakit v1.0
# Routing for iOS-client
# 
###

breaks				= require '../models/breakModel'
albums				= require '../models/albumModel'
comments			= require '../models/commentModel'
notifications	= require '../models/notificationsModel'
pushNotifications	= require '../models/pushNotificationModel'
users					= require '../models/userModel'
feedback			= require '../models/feedbackModel'
report				= require '../models/reportModel'
fs						= require 'fs'
qs						= require 'querystring'
async					= require 'async'
easyimg				= require 'easyimage'

#Main page for ios, response sends 10 albums / page, ordered according to distance only.
#The important thing for the client to pick is the albums name, and the topbreak. 
exports.index = (req, res) ->
	
	console.log 'req.body.lat: '+req.body.lat
	console.log 'req.body.lon: '+req.body.lon
	console.log 'req.body: '+req.body
	#console.log 'new request of feed with lon: ' + req.body.lon +' & lat: ' + req.body.lat
	console.log 'request shownBreaks: '+req.shownBreaks

	#Change page and location to numbers
	page	= parseInt req.body.page, 10
	lon		= parseFloat req.body.lon
	lat		= parseFloat req.body.lat
	shown	= null
	
	console.log 'request page: '+page
	console.log 'shownBreaks: '+req.body.shownBreaks
	
	if req.body.shownBreaks
		tempstr = req.body.shownBreaks.substring(1, req.body.shownBreaks.length - 1)
		console.log tempstr
		shown = tempstr.split ','
		
#	console.log shown
	
	#Get albums sorted according to location
	breaks.getFeed lon, lat, page, shown, (err, breaks) ->
		if err
			throw err
			res.send '404'
		else
			#Send the albums as a JSON to client
			for b in breaks
				console.log 'sending back to client: '+b._id
			res.send [breaks, page]


exports.login = (req, res) 	->
	console.log 'IN LOGIN!!!'
	console.log 'Login received from user: ' + req.body.userId
	users.findById req.body.userId, (err, user) ->
		if err
			console.log err
			res.send 'error'
		else if user is null
			console.log 'Handled an erroneus login.'
			res.send 'error'
		else if user.token is null
			console.log 'token is null'
			res.send 'confirmed'
			# if the user that can be found with the userid has a token do nothing
			# else update the token
		else if user.token
			console.log 'Login successful.'
			res.send 'confirmed'
		else if req.body.token
			console.log 'in setting req.body.token '
			console.log 'in setting req.body.token: ' + req.body.token
			list = {}
			list['userId'] = req.body.userId
			list['token'] = req.body.token
			console.log 'LIST: ' + req.body.token
			users.changeAttributes list, () ->
				console.log 'changing attributes'
				if err
					console.log 'ERROR IN SETTING THE TOKEN'
					res.send 'error'
				else
					console.log 'SUCCESS IN SETTING THE TOKEN'
					res.send 'confirmed'
		else if req.body.version
			console.log 'version: ' + req.body.version
			console.log 'no token found, token sent: '+req.body.token
			console.log 'no token found, user.token: '+user.token
			res.send 'sendToken'
		else
			console.log 'SEND CONFIRMED in the last else!!! '
			res.send 'confirmed'

#Creates a new user and responds with the userId
exports.newUser = (req, res) ->
	res.set 'Content-Type', 'application/json'	
	console.log 'New user requested. Nickname: ' + req.body.nickname + '. Device token: '+req.body.token
	users.createUser req.body.nickname, 'iPhone', req.body.token, (err, user) ->
		if err
			console.log err
			res.send 'Taken.'
		else
			res.send user

#create a new break
exports.postBreak = (req, res) ->
	
	console.log 'place id: ' + req.body.placeId
	console.log 'place name: ' + req.body.placeName
	console.log 'req.body.longitude: ' + req.body.longitude
	console.log 'req.body.latitude: ' + req.body.latitude
	console.log 'headline: ' + req.body.headline
	console.log 'userid: ' + req.body.userId

	breaks.createBreak req.body.longitude, req.body.latitude, req.body.placeName, req.body.placeId, req.body.story, req.body.headline, req.body.userId, (err, break_) ->
		
		#Only if the break should be in an album...
		if break_.placeId != undefined
			console.log 'Adding a new break to an album.'
			albums.addBreak break_
		
		tmp_path = req.files.image.path
		#TODO error handling. If the path is not present, bad things happen. This should be handled in validations
		target_path ='./app/res/user/' + req.body.userId + '/images/' + break_._id + '.jpeg'
		fs.readFile tmp_path, (err, data) ->
			if err
				throw err
			fs.writeFile target_path, data, (err) ->
				if err
					throw err
					res.send err
				else
					easyimg.thumbnail {
					src: './app/res/user/' + req.body.userId + '/images/' + break_._id + '.jpeg', dst: './app/res/user/' + req.body.userId + '/images/thumbs/' + break_._id + '.jpeg', width: 128, height:128,x:0,y:0}, (err, image)->
						if err
							console.log 'error in creating thumb'
						else
							console.log 'success in creating a thumbnail'
							breaks.findById break_._id, (err, b) ->
								if err
									throw err
								else
									res.send b

exports.deleteBreak = (req, res) ->
	console.log 'Request to delete Break: ' + req.body.breakId + ' by user: ' + req.body.userId
	
	#userId not used atm
	
	breaks.del req.body.breakId, (err) -> 
		if err
			res.send 'Break delete failed.' 
		else
			res.send 'Break deleted successfully.'
			
exports.reportBreak = (req, res) ->
	console.log 'Reported an inappropriate Break: ' + req.body.breakId + ' by user: ' + req.body.userId

	report.createReport req.body.breakId, req.body.userId, (err) ->
		if err
			res.send 'Break reporting failed.'
		else
			res.send 'Break reported successfully.'
					
exports.postComment = (req, res) ->
	users.findById req.body.userId, (err, author) ->
		if not author
			res.send 'Invalid user.'
		else
			newComment = new comments.Comment req.body.comment, req.body.userId, author.nName
			breaks.comment newComment, req.body.breakId, (err, commentCount) ->
				if err
					res.send 'Commenting failed.'
				else
					res.send newComment

#Takes a req that contains 3 fields: "breakId", "userId"" and "which" ('up' or 'down')
exports.vote = (req, res) ->
	breaks.vote req.body.breakId, req.body.userId, req.body.which, (err, break_) ->
		if err
			console.log err
			res.send 'Vote failed'
		else
			res.send break_

exports.getPicture = (req, res) ->
	id = req.params.id
	breaks.findById id, (err, break_) ->
		if err
			throw err
		res.sendfile './app/res/user/' + break_.user + '/images/' + break_.id + '.jpeg'

#not needed anymore?
exports.getBreak = (req, res) ->
	breaks.findById req.params.id, (err, b) ->
		if not b
			console.log err
			res.send 'Could not find the break'
		else
			res.send b

exports.tweet = (req, res) ->
	breaks.tweet req.body.breakId, req.body.userId, (err) ->
		if err
			console.log err
			res.send 'Saving the tweet to server failed'	
		else
			res.send 'Saved the tweet successfully to server'
	
	
exports.fbShare = (req, res) ->
	
	console.log 'New FB share by user: ' + req.body.userId
	
	breaks.fbShare req.body.breakId, req.body.userId, (err) ->
		if err
			console.log err
			res.send 'Saving the Facebook share to server failed'
		else
			res.send 'Saved the Facebook share successfully to server'


exports.browseAlbum = (req, res) ->
	console.log 'Getting page ' + req.params.page + ' in album ' + req.params.albumId
	albums.getBreak req.params.albumId, req.params.page, (err, break_) ->
		if err
			throw err
		else
			breaks.addView break_._id, (err, break_) ->
				if err
					throw err
			console.log 'Sending new break info for break: ' + break_._id
			res.send break_

exports.feedbackCreate = (req, res) ->
	console.log 'HANDLING A REQUEST FROM IOS: ' + req.body
	feedback.createFeedback req.body, (err) ->
		if err
			console.log err
			res.send 'Error saving feedback'
		else
			console.log 'SUBMITTED'
			res.send 'SUCCESS'

exports.changeUserAttributes = (req, res) ->
# needs a json object from the client with userid and a key value pair where key = user's field to be changed and value = new value	
	users.changeAttributes req.body, (err, user)->
		if err 
			res.send 'error'
		else
			res.send user

exports.getAlbumBreaks = (req, res) ->
	
	console.log 'Getting Album Breaks: ' + req.params.albumId + ', page: ' + req.params.page
	
	albums.getAlbumBreaks req.params.albumId, req.params.page, (err, foundBreaks)->
		if err
			res.send 'error'
		else
			res.send [foundBreaks, req.params.page]

exports.getMyBreaks = (req, res) ->
	
	users.getBreaks req.params.userId, req.params.page, (err, foundBreaks)->
		if err
			res.send 'error'
		else
			res.send [foundBreaks, req.params.page]
			

exports.getWelcomeScreenPics = (req, res) ->
	# GET THE LON AND LAT FROM THE REQUEST
	picsToShow = []
	breaks.getFeed 23.889313, 60.288854, 1, null, (err, breaks) ->
		if err
			throw err
			res.send '404'
		else
			res.writeHead 200, {'Content-Type': 'text/html'}
			res.write '<html><body>'
			async.forEach breaks, (b, callback) ->
				console.log 'break: '+b
				fs.readFile './app/res/user/' + b.user + '/images/' + b._id + '.jpeg', (err, file)->
					if err
						console.log 'PICTURE: '+ file
						console.log 'ERROR IN READING PICTURE!'
					else
						console.log 'Pushing a new file: '+b._id+' to picsToShow'
						res.write '<img src="data:image/jpeg;base64,'
						res.write new Buffer(file).toString('base64')
						res.write '"/>'
						console.log 'wrote the html'
						callback

				### CODE TO RESIZE THE IMAGES 
				easyimg.resize {
					src: './app/res/user/' + b.user + '/images/' + b._id + '.jpeg', dst: './app/res/user/' + b.user + '/images/' + b._id + '_thumb.jpeg', width: 80, height:80}, (err, image)->
				###

exports.getMyNotifications = (req, res) ->
	notifications.getNotifications req.params.userId, (err, foundNotifications)->
		if err
			res.send 'error'
		else
			list = []
			i = 0
			res.send foundNotifications

### What is this??
			for notification in foundNotifications
				list[i] = 'User: '+notification.user_id_from + 'commented: "'+notification.comment+'" on your break'+notification.user_id_to+'<br />'
				i++
###

exports.sendPushNotification = (req, res) ->
	console.log 'request: : ' + req
	console.log 'request body: : ' + req.body
	console.log 'userId: ' + req.body.userId
	console.log 'messageId: ' + req.body.msgId
	pushNotifications.send req.body.userId, req.body.msgId, (err, foundUser) ->
		if err
			res.send 'error'
		else
			res.send 'success'
