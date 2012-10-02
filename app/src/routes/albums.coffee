albums = require '../models/albumModel'

exports.list = (req, res) ->
	
	albums.list (albums) ->	
		res.render 'albumlist', title : 'Breakit albumlist', albums: albums

exports.create = (req, res) ->
	res.render 'newAlbum', title : 'Create a new album'
	
exports.submit = (req, res) ->
	
	name = req.body.name 
	
	newAlbum = new albums.Album name, null, null, (album) ->