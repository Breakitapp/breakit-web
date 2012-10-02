models = require './mongoModel'
_ = require 'underscore'

class Album
	constructor: (@name, @breaks, @topBreak, callback) ->
		callback @

	saveToDB : () ->
		album = new models.Album
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
	
	console.log 'name: ' + name
	
	###models.Album.db.db.executeDbCommand {
		geoNear: 'albums' 
		near : loc
		spherical : true
		}, (err, docs) ->
			if err
				throw err
			b = docs.documents[0].results
			if b[0] and b[page*10]
				i = 0
				while b[page*10+i] and i < 10
					object = b[page*10+i]
					found_break = object.obj
					found_break.dis = object.dis
					breaks.push found_break
					i++
			#TODO handling of the last breaks modulus
			callback null, breaks
	return breaks###
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

addBreak = (b) ->
	find b.location_name,  (album) ->
		if album is null
			console.log 'ALBUM: Adding break and creating new album ' + b.location_name
			jsalbum = new Album b.location_name, [b], b, (album) ->
				album.saveToDB()
				console.log "ALBUM: what we just saved " + album.location
				return
		else
			album.breaks.push b
			if album.topBreak is null or album.topBreak.score < b.score
				console.log 'ALBUM: changing the topbreak'
				album.topBreak = b
			album.save (err) ->
				console.log 'ALBUM: saving new break' + b.headline + ' to ' + album.name
				if err
					throw err

remove = (id) ->
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
	models.Album.find({'name': album}).exec((err, docs) ->
		if docs is not null and docs[1] is not null
			b = docs[0].breaks
			b.splice 0,1
			callback err, b
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
