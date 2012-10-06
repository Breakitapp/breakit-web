models = require './mongoModel'
_ = require 'underscore'

#TODO add location for album
class Album
	constructor: (@longitude, @latitude, @name, @breaks, @topBreak, callback) ->
		callback @

	saveToDB : () ->
		album = new models.Album
			loc				:	{lon: @longitude, lat: @latitude}
			name			: @name
			breaks		:	@breaks
			topBreak	: @topBreak
		album.save (err) ->
			if err
				throw err
			console.log 'ALBUM: created a new album ' + album.name + ' with topBreak ' + album.topBreak

createFromId = (id) ->
	models.Album.findById id, (err, album) ->
		if err
			throw err
		else
			newAlbum = new Album album.name, album.location, album.breaks, album.topBreak
			return newAlbum

find = (name, callback) ->
	models.Album.findOne name: name, (err, album) ->
		if err
			throw err
		else
			callback album
			return album

list = (callback) ->
	models.Album.find().exec (err, data) ->
		if err
			throw err
		else
			albums = (album for album in data)
			callback albums

#Finds albums relative to location and returns max 10 albums. Takes in location from the request in Album routes
findNear = (longitude, latitude, page, callback) ->
	albums = []
	#This is the geonear mongoose function, that searches for locationbased nodes in db
	models.Album.db.db.executeDbCommand {
		geoNear: 'albums' 
		near : loc
		spherical : true
		}, (err, docs) ->
			if err
				throw err
			a = docs.documents[0].results
			if a[0]
				i = 0
				while a[page*10+i] and i < 10
					object = a[page*10+i]
					found_album = object.obj
					found_album.dis = object.dis
					found_album.breaks = null
					albums.push found_album
					i++
			callback null, albums
	return breaks
	
addBreak = (b) ->
	find b.location_name,  (album) ->
		if album is null
			console.log 'ALBUM: Adding break and creating new album ' + b.location_name
			jsalbum = new Album b.longitude, b.latitude, b.location_name, [b], b, (album) ->
				album.saveToDB()
				console.log "ALBUM: what we just saved " + album.location
				return
		else
			album.breaks.push b
			if album.topBreak is null or album.topBreak.score < b.score
				console.log 'ALBUM: changing the topbreak'
				album.topBreak = b
			album.save (err) ->
				console.log 'ALBUM: saving new break ' + b.headline + ' to ' + album.name
				if err
					throw err

remove = (id) ->
	#This need to iteratively remove all breaks too
	models.Album.findByIdAndRemove id, (err) ->
		if err
			throw err
		else
			console.log 'ALBUM: removed the album correctly' 

# get the next page content according to location and points
nextFeed = (array, best, page, userLocation) ->
	_.without(best)
	range = 50+50*page
	# get closest X elements, depending on which page the user is in. They are the first as the array is sorted by location
	closest = _.first(array, range)
	# sort by points
	sorted = _.sortBy(closest, topBreak)
	best = _.first(closest, 10)

findBreak = (album, page, callback) ->
	models.Album.find({'name': album}).sort({'points':'descending'}).exec((err, docs) ->
		if docs is not null and docs[1] is not null
			breaks = []
			b = docs[0].breaks
			#This splice removes the top break, could be done with an if statement too
			b.splice 0,1
			if b[0]
				i = 0
				while b[page*10+i] and i < 10
					found_break = b[page*10+i]
					breaks.push found_break
					i++
				callback err, breaks
		else
			callback err, docs
	)

root = exports ? window
root.Album = Album
root.find = find
root.list = list
root.remove = remove
root.addBreak = addBreak
root.createFromId = createFromId
root.findBreak = findBreak
root.findNear = findNear
