###
# Breakit v1.0
# Routing for iOS-client
# 
###

breaks	= require '../models/breakModel'
albums	= require '../models/albumModel'
comments = require '../models/commentModel'
fs			= require 'fs'

#Main page for ios, response sends 10 albums / page, ordered according to distance only.
#The important thing for the client to pick is the albums name, and the topbreak. 
exports.index = (req, res) ->
	#Change page and location to numbers
	page	= parseInt req.body.page, 10
	lon		= parseFloat req.body.lon
	lat		= parseFloat req.body.lat
	#Get albums sorted according to location
	albums.findNear lon, lat, page, (err, albums) ->
		if err
			throw err
			res.send '404'
		else
			#Send the albums as a JSON to client
			res.send [albums, page]


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
				else
					breaks.findById break_._id, (err, b) ->
						if err
							throw err
						else
							res.send b
					
exports.post_comment = (req, res) ->
	console.log req.body
	newComment = new comments.Comment req.body.comment, req.body.user
	breaks.comment newComment, req.body.breakId, (err, commentCount) ->
		if err
			res.send 'Commenting failed.'
		else
			res.send newComment

#Simplified voting functionality
#Takes a req that contains 2 fields: "breakId" and "which" ('up' or 'down')
exports.vote = (req, res) ->
	breaks.vote req.body.breakId, req.body.which, (err, score) ->
		if err
			res.send 'Vote failed'
		else
			console.log 'res: ' + score
			res.send score

exports.get_picture = (req, res) ->
	id = req.params.id
	
	res.sendfile './app/res/images/' + id + '.jpeg'

exports.get_break = (req, res) ->
	breaks.findById req.params.id, (err, b) ->
		if err
			res.send err
		else
			res.send b


exports.get_breaks_from_album = (req, res) ->
	console.log 'GETTING ALBUM PAGE ' + req.body
	album = req.params.album
	page = req.params.page
	albums.findBreak album, page, (err, docs) ->
		if err
			throw err
		res.send docs
