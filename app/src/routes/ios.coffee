###
# Breakit v1.0
# Routing for iOS-client
# 
###

breaks	= require '../models/breakModel'
fs			= require 'fs'

#Main page for ios, response sends 10 breaks / page, ordered according to distance only.
exports.index = (req, res) ->
	console.log req.body
	#Change page and location to numbers
	page	= parseInt req.body.page, 10
	lon		= parseFloat req.body.lon
	lat		= parseFloat req.body.lat
	#Get breaks sorted according to location
	breaks.findNear lon, lat, page, (err, breaks) ->
		if err
			throw err
			res.render '404'
		else
			#Send the breaks as a JSON to client
			res.send breaks

#create a new break
exports.post_break = (req, res) ->
	console.log req.body
	breaks.createBreak req.body, (err, break_) ->
		tmp_path = req.files.image.path
		target_path = '../../res/user/' + req.body.user + '/images/' + break_._id + '.png'
		fs.readFile tmp_path, (err, data) ->
			if err
				throw err
			fs.writeFile target_path, data, (err) ->
				if err
					throw err
					res.send err
				res.send 'Break sent'
