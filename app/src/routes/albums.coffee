albums = require '../models/albumModel'

exports.list = (req, res) ->	
	albums.list (albums) ->	
		res.render 'blocks/albumList', title : 'Breakit albumlist', albums: albums
