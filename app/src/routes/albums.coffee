albums = require '../models/albumModel'

exports.list = (req, res) ->
	
	albums.list (albums) ->	
		res.render 'albumlist', title : 'Breakit albumlist', albums: albums

exports.create = (req, res) ->
	res.render 'newAlbum', title : 'Create a new album'
	
exports.submit = (req, res) ->
	
	name = req.body.name 
	
	new albums.Album name, null, null, (album) ->
		
		album.saveToDB () ->
		res.send 'Created a new album: ' + album.name