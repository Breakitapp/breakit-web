###
# Breakit v1.0
# Routing for iOS-client
# 
###

breaks	= require '../models/breakModel'
albums	= require '../models/albumModel'
comments = require '../models/commentModel'
fs			= require 'fs'

#Main page for ios, response sends 10 breaks / page, ordered according to distance only.
exports.index = (req, res) ->
	#Change page and location to numbers
	page	= parseInt req.body.page, 10
	lon		= parseFloat req.body.lon
	lat		= parseFloat req.body.lat
	#Get breaks sorted according to location
	breaks.findNear lon, lat, page, (err, breaks) ->
		if err
			throw err
			res.send '404'
		else
			#Send the breaks as a JSON to client
			res.send [breaks, page]


#create a new break
exports.post_break = (req, res) ->
	breaks.createBreak req.body, (err, break_) ->
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
				breaks.findById break_._id, (err, b) ->
					if err
						throw err
					res.send b
					
exports.post_comment = (req, res) ->
	
	console.log req
	
	newComment = new comments.Comment req.comment, req.user
	breaks.comment newComment, req.breakId, (err, commentCount) ->
		if err
			res.send 'Commenting failed.'
		else
			res.send newComment, commentCount

exports.get_break = (req, res) ->
	id = req.params.id
	res.sendfile './app/res/images/' + id + '.jpeg'


exports.get_breaks_from_album = (req, res) ->
	console.log 'GETTING ALBUM PAGE ' + req.body
	album = req.params.album
	page = req.params.page
	albums.findBreak album, page, (err, docs) ->
		if err
			throw err
		res.send docs
