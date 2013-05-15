models = require './mongoModel'
breakModel = require './breakModel'
async = require 'async'
_ = require 'underscore'

#TODO add location for album
class Album
	constructor: (@lon, @lat, @placeId, @name) ->

	saveToDB : (callback) ->
		album = new models.Album
			loc			:	{lon: @lon, lat: @lat}
			placeId		: 	@placeId
			name		:	@name
		album.save (err) ->
			if err
				throw err
			else
				console.log 'ALBUM: created a new album ' + album.name + ' @ ' + album.loc
				callback album._id

findByName = (name, callback) ->
	models.Album.findOne name: name, (err, foundAlbum) ->
		callback err, foundAlbum
		
findByPlace = (place, callback) ->
	models.Album.findOne placeId: place, (err, foundAlbum) ->
		callback err, foundAlbum
			
findById = (id, callback) ->
	models.Album.findById(id).exec (err, foundAlbum) ->
		callback err, foundAlbum

list = (callback) ->
	models.Album.find().exec (err, data) ->
		if err
			throw err
		else
			albums = (album for album in data)
			callback albums

addBreak = (b) ->
	models.Album.findOne(placeId: b.placeId).exec (err, album) -> 		
		if err
			console.log err
			throw err
		if album
			b.album = album._id
			
			b.save (err) ->
				if err
					throw err
				else
					console.log 'ALBUM: saved new break ' + b._id + ' to ' + album.name
			
		else
			console.log 'ALBUM: Adding break ' + b.headline + ' and creating new album ' + b.placeName
			newAlbum = new Album b.loc.lon, b.loc.lat, b.placeId, b.placeName
			newAlbum.saveToDB (albumId) ->
				b.album = albumId
				#b.top = true		
				b.save (err) ->
					if err
						throw err

#Returns the next break in an album according to points
getBreak = (albumId, page, callback) ->
	models.Break.find({album: albumId}).sort({points: 'descending'}).exec (err, docs) ->
		if docs isnt null	
						
			while page < 0
				page = Number(page) + Number(docs.length)
									
			if page >= docs.length
				page = page % docs.length
						
			callback err, docs[page]
	
		else
			console.log 'is null'
			callback err, null

#Returns 287 (3*9) breaks for the album-specific view
getAlbumBreaks = (albumId, page, callback) ->
	models.Break.find({'album' : albumId}).sort({points: 'descending'}).skip(27*page).limit(27).exec (err, breaks) ->
		if err
			callback err, null
		else
			breaks_ = (b for b in breaks)
			callback null, breaks_
			return breaks_

getAlbumSize = (albumId, callback) ->
	models.Break.count {'album' : albumId}, (err, size) ->
		if err
			callback err, null
		else
			callback null, size
		return size

	#This need to iteratively remove all breaks too? Or atleast remove the album field from them.
remove = (id) ->
	models.Album.findByIdAndRemove id, (err) ->
		if err
			throw err
		else
			console.log 'ALBUM: removed the album correctly'

root = exports ? window
root.Album = Album
root.findByName = findByName
root.findByPlace = findByPlace
root.findById = findById
root.list = list
root.addBreak = addBreak
root.getBreak = getBreak
root.getAlbumBreaks = getAlbumBreaks
root.getAlbumSize = getAlbumSize
root.remove = remove

