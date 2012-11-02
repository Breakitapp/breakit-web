###
# Breakit v1.0
# Routing for iOS-client
# 
###

breaks	= require '../models/breakModel'
albums	= require '../models/albumModel'
comments = require '../models/commentModel'
users = require '../models/userModel'
feedback = require '../models/feedbackModel'
fs			= require 'fs'

#Main page for ios, response sends 10 albums / page, ordered according to distance only.
#The important thing for the client to pick is the albums name, and the topbreak. 
exports.index = (req, res) ->
	#Change page and location to numbers
	page	= parseInt req.body.page, 10
	lon		= parseFloat req.body.lon
	lat		= parseFloat req.body.lat
	
	console.log page
	console.log req.body.shownAlbums
	if req.body.shownAlbums
		tempstr = req.body.shownAlbums.substring(1, req.body.shownAlbums.length - 2)
		arr = tempstr.split ','
		console.log arr
		
	
	#Get albums sorted according to location
	albums.getFeed lon, lat, page, arr, (err, albums) ->		
		if err
			throw err
			res.send '404'
		else
			#Send the albums as a JSON to client
			res.send [albums, page]


exports.login = (req, res) ->
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
	breaks.createBreak req.body.longitude, req.body.latitude, req.body.location_name, req.body.story, req.body.headline, req.body.userId, (err, break_) ->
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

#Simplified voting functionality
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

exports.changeNickname = (req, res) ->
	console.log 'in change Nickname'

#TO BE IMPLEMENTED GETTING THE new_nickname FROM ios request
	new_nickname = req.body.new_nickname
	new_nickname = "marko"
	nicknames = '{"fields":[{"nname":"'+new_nickname+'"}]}'
	arr = JSON.parse(nicknames);
#TO BE IMPLEMENTED GETTING THE userId FROM ios request
	userId = req.body.userid
	userId = "50911d3a1f2b125409000001"

	users.changeAttributes userId, arr.fields, (err, user)->
		if err 
			res.send 'ERROR IN CHANGING NICKNAME'
		else
			res.send user.nName

     # get the nickname from the request

#		res.send 'changing the nickname'

     # do db operations to change the nickname in the db
     # if success return the new nickname to the client

exports.getAlbumBreaks = (req, res) ->
	albumId = req.body.albumId
#dummy albumid
#dummy page
	albumId = '508fd53496c69b4c0d000002'
	page = 0
	albums.getAlbumBreaks albumId, page, (err, foundBreaks)->
		if err
			res.send 'returns error'
		else
			res.send 'returns: '+foundBreaks
