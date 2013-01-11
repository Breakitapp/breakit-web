breaks = require '../models/breakModel'
albums = require '../models/albumModel'
users = require '../models/userModel'
comments = require '../models/commentModel'
fs			= require 'fs'

#This is only for web interface	
exports.list = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		breaks.findAll (err, breaks_) ->
			if err
				res.send 'No breaks found.'
			else
				#TODO change the breakslist.jade to follow the guidelines of templating.
				res.render 'tests/breakslist', title : 'All breaks', breaks: breaks_
###
exports.searchMedia= (req, res) ->
	x = req.body.searchValue
	breaks.searchBreaks x, (err, breaks_) ->
		if err
			res.send 'No breaks found.'
		else
			res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_
###
exports.infinite = (req, res) ->
	page = req.params.page
	breaks.findInfinite page, (err, docs) ->
		res.send docs

#This is only for web interface		
exports.easyWebCreate = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		res.render 'tests/easyNewBreak', title : 'Create a new Break'

#Markon
exports.easyWebSubmit = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		#PARSE request
		parsed = req.body.location.split '#'
		headline = 'Marko chilling in' + parsed[3]
		story = 'WOOHOOO :) :) Having SUPER DUPER TIME in'+ parsed[3]
	#lon,lat,loc_name,story, headline, user, callback
		breaks.createBreak parsed[2], parsed[1], parsed[3], story, headline, 'marko3345', (err, break_) ->
			console.log 'created a break'+break_
			albums.addBreak break_
			
			target_path ='./app/res/images/' + break_._id + '.jpeg'
			fs.readFile './test/images/P1030402.JPG', (err, data) ->
				if err
					console.log err
					res.send 'Error reading image'
				else
					fs.writeFile target_path, data, (err) ->
						if err
							console.log err
							res.send 'Error saving image'
						else
							res.send 'New break saved successfully'

#This is only for web interface	
exports.webCreate = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		res.render 'newBreak', title : 'Create a new Break'

#This is only for web interface	
exports.webSubmit = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		
		console.log 'placeId: ' + req.body.placeId
		
		breaks.createBreak req.body.longitude, req.body.latitude, req.body.placeName, req.body.placeId, req.body.story, req.body.headline, req.body.userId, (err, break_) ->
			albums.addBreak break_
			
			target_path ='./app/res/images/' + break_._id + '.jpeg'
			fs.readFile req.files.image.path, (err, data) ->
				if err
					console.log err
					res.send 'Error reading image'
				else
					fs.writeFile target_path, data, (err) ->
						if err
							console.log err
							res.send 'Error saving image'
						else
							res.send 'New break saved successfully'


#This is only for web interface	
exports.comment = (req, res) ->
	res.render 'blocks/comment', title : 'Create a new comment'

#This is only for web interface		
exports.postComment = (req, res) ->
	users.findById req.body.userId, (err, author) ->
		if err
			throw err
		else
						
			newComment = new comments.Comment req.body.comment, req.body.userId, author.nName
	
			console.log 'new comment: ' + newComment.comment
			breaks.comment newComment, req.body.breakId, (err, commentCount) ->
				if err
					res.send 'Commenting failed.'
				else
					res.send 'Commenting successful. Count: ' + commentCount

#req needs to contain "which" field ('up' or 'down') and "breakId" field
exports.vote = (req, res) ->
	breaks.vote req.body.breakId, req.body.userId, req.body.which, (err, score) ->
		if err
			console.log err
			res.send 'Vote failed'
		else
			res.redirect('/breaks/')

exports.delete = (req, res) ->
	breaks.del req.body.breakId, req.body.userId, (err) ->
		if err
			console.log err
			res.send 'Deleting failed.'
		else
			res.redirect('/breaks/')
	
