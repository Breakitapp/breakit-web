breaks = require '../models/breakModel'
albums = require '../models/albumModel'
comments = require '../models/commentModel'
fs			= require 'fs'

exports.list = (req, res) ->
	breaks.findNear 100, 65, 0, (err, docs) ->
		res.send docs

#This is only for web interface	
exports.listall = (req, res) ->
	
	breaks.findAll (err, breaks_) ->
		if err
			res.send 'No breaks found.'
		else
			res.render 'breakslist', title : 'All breaks', breaks: breaks_

exports.infinite = (req, res) ->
	page = req.params.page
	breaks.findInfinite page, (err, docs) ->
		res.send docs

#This is only for web interface		
exports.easyWebCreate = (req, res) ->
	res.render 'easyNewBreak', title : 'Create a new Break'

exports.easyWebSubmit = (req, res) ->
	#PARSE request
	parsed = req.body.location.split '#'
	headline = 'Marko chilling in' + parsed[3]
	story = 'WOOHOOO :) :) Having SUPER DUPER TIME in'+ parsed[3]

	breaks.createBreak parsed[1], parsed[2], parsed[3], story, headline, (err, break_) ->
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
	res.render 'newBreak', title : 'Create a new Break'

#This is only for web interface	
exports.webSubmit = (req, res) ->
	
	console.log 'cookie: ' + req.cookie
			
	breaks.createBreak req.body.longitude, req.body.latitude, req.body.location_name, req.body.story, req.body.headline,  (err, break_) ->
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
	res.render 'comment', title : 'Create a new comment'

#This is only for web interface		
exports.postComment = (req, res) ->
	console.log req.body
	
	newComment = new comments.Comment req.body.comment, req.body.user
	
	console.log 'new comment: ' + newComment.comment
	breaks.comment newComment, req.body.breakId, (err, commentCount) ->
		if err
			res.send 'Commenting failed.'
		else
			res.send 'Commenting successful. Count: ' + commentCount

#req needs to contain "which" field ('up' or 'down') and "breakId" field
exports.vote = (req, res) ->
	breaks.vote req.body.breakId, req.body.which, (err, score) ->
		if err
			res.send 'Vote failed'
		else
			res.redirect('/breaks/all')
			
exports.cookieGet = (req, res) ->
	res.render 'cookieTest', title : 'Cookie stuff'
	
exports.cookiePost = (req, res) ->
	