models = require './mongoModel'
_ = require 'underscore'

class Album
	constructor: (@name, @location = [60.188289, 24.83739], @breaks = null, @topBreak = null, callback) ->
		callback @

	saveToDB : () ->
		album = new models.Album
			name			: @name
			location	: @location
		album.save (err) ->
			if err
				throw err
			console.log 'ALBUM: created a new album ' + @name

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

addBreak = (name, b) ->
	find name, (album) ->
		if album is null
			console.log 'ALBUM: Adding break and creating new album ' + b.location_name
			jsalbum = new Album b.location_name, [b.longitude, b.latitude], [], null, (album) ->
				album.breaks.push b
				album.topBreak = b
				album.saveToDB()
				console.log "ALBUM: what we just saved " + album
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
	models.Album.find({'name': album}).sort({'topBreak.score': 'desc'}).skip(page).limit(1).exec((err, docs) ->
		console.log 'ALBUM Finding pictures'
		callback err, docs
	)

root = exports ? window
root.Album = Album
root.find = find
root.remove = remove
root.addBreak = addBreak
root.createFromId = createFromId
root.findBreak = findBreak
