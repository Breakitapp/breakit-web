breaks = require '../models/breakModel'
albums = require '../models/albumModel'
comments = require '../models/commentModel'
fs			= require 'fs'

exports.list = (req, res) ->
	breaks.findNear 100, 65, 65, (err, docs) ->
		res.send docs

#This is only for web interface	
exports.listall = (req, res) ->
	breaks.findAll (err, breaks_) ->
		if err
			res.send 'No breaks found.'
		else
		
			for b in breaks_
				console.log b
			res.render 'breakslist', title : 'All breaks', breaks: breaks_

exports.infinite = (req, res) ->
	page = req.params.page
	breaks.findInfinite page, (err, docs) ->
		res.send docs

#Does someone have a plan for this function? (not me -E)
###
exports.create = (req, res) ->
	breaks.create
###

#This is only for web interface	
exports.webCreate = (req, res) ->
	res.render 'newBreak', title : 'Create a new Break'
	
#This is only for web interface	
exports.webSubmit = (req, res) ->
	
	console.log req.files
	console.log req.files.image.path
	
	###
	lon = (Number) req.body.longitude
	lat = (Number) req.body.latitude
	name = req.body.location_name
	story = req.body.story
	headline = req.body.headline
	###
		
	breaks.createBreak req.body, (err, break_) ->
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