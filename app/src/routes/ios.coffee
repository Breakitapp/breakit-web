###
# Breakit v1.0
# Routing for iOS-client
# 
###

breaks	= require '../models/breakModel'
albums	= require '../models/albumModel'
comments = require '../models/commentModel'
notifications = require '../models/notificationsModel'
users = require '../models/userModel'
feedback = require '../models/feedbackModel'
report = require '../models/reportModel'
fs			= require 'fs'
qs = require('querystring')

#Main page for ios, response sends 10 albums / page, ordered according to distance only.
#The important thing for the client to pick is the albums name, and the topbreak. 
exports.index = (req, res) ->
	
	console.log 'new request object: '+req
	console.log 'request shownBreaks: '+req.shownBreaks
	#Change page and location to numbers
	page	= parseInt req.body.page, 10
	lon		= parseFloat req.body.lon
	lat		= parseFloat req.body.lat
	shown 	= null

	console.log 'lon: '+lon
	
	if req.body.shownBreaks
		tempstr = req.body.shownBreaks.substring(1, req.body.shownBreaks.length - 1)
		console.log tempstr
		shown = tempstr.split ','
		
	console.log shown
	
	#Get albums sorted according to location
	breaks.getFeed lon, lat, page, shown, (err, breaks) ->
		if err
			throw err
			res.send '404'
		else
			#Send the albums as a JSON to client
			res.send [breaks, page]


exports.login = (req, res) 	->
	console.log 'Login received from user: ' + req.body.userId
	
	users.findById req.body.userId, (err, user) ->
		if err
			console.log err
			res.send 'error'
		else if user is null
			console.log 'Handled an erroneus login.'
			res.send 'error'
		else
			console.log 'Login successful.'
			res.send 'confirmed'

#Creates a new user and responds with the userId
exports.new_user = (req, res) ->
	
	console.log 'New user requested. Nickname: ' + req.body.nickname
	
	users.createUser req.body.nickname, 'iPhone', (err, user) ->
		if err
			console.log err
			res.send 'User creation failed'
		else
			console.log 'New user ' + user._id + ' sent to the client.'
			res.send user

#create a new break
exports.post_break = (req, res) ->
	
	console.log 'place id: ' + req.body.placeId
	console.log 'place name: ' + req.body.placeName
	#
	breaks.createBreak req.body.longitude, req.body.latitude, req.body.placeName, req.body.placeId, req.body.story, req.body.headline, req.body.userId, (err, break_) ->
		
		#Only if the break should be in an album...
		if break_.placeId != undefined
			console.log 'Adding a new break to an album.'
			albums.addBreak break_
		
		tmp_path = req.files.image.path
		# for future target_path = '../../../web/public/res/user/' + req.body.user + '/images/' + break_._id + '.png'
		target_path ='./app/res/images/' + break_._id + '.jpeg'
		fs.readFile tmp_path, (err, data) ->
			if err
				throw err
			fs.writeFile target_path, data, (err) ->
				if err
					throw err
					res.send err
				else
					breaks.findById break_._id, (err, b) ->
						if err
							throw err
						else
							res.send b

exports.delete_break = (req, res) ->
	console.log 'Request to delete Break: ' + req.body.breakId + ' by user: ' + req.body.userId
	
	breaks.del req.body.breakId, req.body.userId, (err) ->
		if err
			res.send 'Break delete failed.' 
		else
			res.send 'Break deleted successfully.'
			
exports.report_break = (req, res) ->
	console.log 'Reported an inappropriate Break: ' + req.body.breakId + ' by user: ' + req.body.userId

	report.createReport req.body.breakId, req.body.userId, (err) ->
		if err
			res.send 'Break reporting failed.'
		else
			res.send 'Break reported successfully.'
					
exports.post_comment = (req, res) ->
	users.findById req.body.userId, (err, author) ->
		if err
			throw err
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

exports.get_picture = (req, res) ->
	id = req.params.id
	
	res.sendfile './app/res/images/' + id + '.jpeg'

#not needed anymore?
exports.get_break = (req, res) ->
	breaks.findById req.params.id, (err, b) ->
		if err
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


exports.browse_album = (req, res) ->
	console.log 'Getting page ' + req.params.page + ' in album ' + req.params.albumId
	albums.getBreak req.params.albumId, req.params.page, (err, break_) ->
		if err
			throw err
		else
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
			

exports.getMyNotifications = (req, res) ->
	
	notifications.getNotifications req.params.userId, (err, foundNotifications)->
		if err
			res.send 'error'
		else
			list = []
			i = 0
			res.send foundNotifications

			for notification in foundNotifications
				list[i] = 'User: '+notification.user_id_from + 'commented: "'+notification.comment+'" on your break'+notification.user_id_to+'<br />'
				i++
