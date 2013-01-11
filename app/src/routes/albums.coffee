albums = require '../models/albumModel'

exports.list = (req, res) ->	
	if(req.ip isnt '54.247.69.189')
		albums.list (albums) ->	
			res.render 'blocks/albumlist', title : 'Breakit albumlist', albums: albums

exports.listNear = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		page = req.params.page
		console.log 'page: '+page
		if(!page)
			page = 0
		albums.findNear 24.83223594527063, 60.1802242005334, page, (nullvalue, albums) ->
			res.render 'blocks/albumlist_near', title : 'Breakit albumlist', albums: albums
	
exports.create = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		res.render 'newAlbum', title : 'Create a new album'
	
exports.submit = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		name = req.body.name 
		
		new albums.Album name, null, null, (album) ->
			
			album.saveToDB () ->
			res.send 'Created a new album: ' + album.name
