albums = require '../models/albumModel'

exports.list = (req, res) ->	
	albums.list (albums) ->	
		res.render 'albumlist', title : 'Breakit albumlist', albums: albums

exports.listNear = (req, res) ->
	page = req.params.page
	console.log 'page: '+page
	if(!page)
		page = 0
	albums.findNear2 24.83223594527063, 60.1802242005334, page, (nullvalue, albums) ->
		res.render 'albumlist_near', title : 'Breakit albumlist', albums: albums
	
exports.create = (req, res) ->
	res.render 'newAlbum', title : 'Create a new album'
	
exports.submit = (req, res) ->
	
	name = req.body.name 
	
	new albums.Album name, null, null, (album) ->
		
		album.saveToDB () ->
		res.send 'Created a new album: ' + album.name

###
exports.getBreak = (req, res) ->
	albums.getBreak req.params.album, req.params.page, (err, break_) ->
		if err
			throw err
		else
			console.log break_
			res.render 'albumFeed', title : 'Feed', break_: break_
###
			
exports.specifyFeed = (req, res) ->
	res.render 'specifyFeed', title : 'Specify the information for album feed'

exports.feed = (req, res) ->
	albums.getFeed Number(req.body.lon), Number(req.body.lat), Number(req.body.page), null, (err, albs) ->
		if err
			throw err
		else
			console.log albs
			res.redirect '/albums/feed'