breaks = require '../models/breakModel'
albums = require '../models/albumModel'
fs			= require 'fs'

exports.list = (req, res) ->
	breaks.findNear 100, 65, 65, (err, docs) ->
		res.send docs

exports.infinite = (req, res) ->
	page = req.params.page
	breaks.findInfinite page, (err, docs) ->
		res.send docs

exports.create = (req, res) ->
	breaks.create

exports.webCreate = (req, res) ->
	res.render 'newBreak', title : 'Create a new Break'
	
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
