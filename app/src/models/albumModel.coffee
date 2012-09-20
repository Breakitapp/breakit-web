models = require './mongoModel'

class Album
	constructor: (@dbid = null, @name, @location = [60.188289, 24.83739], @breaks = null, @topBreak = null) ->

	save : (callback) ->
		album = new models.Album
			name			: @name
			location	: @location
		
		album.save (err) ->
			if err
				throw err
			else
				console.log 'Saved a new album : ' + @name
				@dbid = album._id

createFromId = (id) ->
	models.Album.findById id, (err, album) ->
		if err
			throw err
		else album
			newAlbum = new Album album._id, album.name, album.location, album.breaks, album.topBreak
			return newAlbum

find = (id, callback) ->
	models.Album.findById id, (err, album) ->
		if err
			throw err
		else
			callback album
			return album

updateAttr = (id, attr, value, callback) ->
	models.Album.findByIdAndUpdate id, attr : value

addBreak = (id, b) ->
	find id, (album) ->
		album.breaks.push b
		album.save (err) ->
			if err
				throw err

remove = (id) ->
	models.Album.findByIdAndRemove id, (err) ->
		if err
			throw err
		else
			console.log 'removed the album correctly' 
