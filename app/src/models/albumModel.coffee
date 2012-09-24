models = require './mongoModel'

class Album
	constructor: (@name, @location = [60.188289, 24.83739], @breaks = null, @topBreak = null, @dbid = null) ->

	save : (callback) ->
		album = new models.Album
			name			: @name
			location	: @location
		album.save (err) ->
			if err
				throw err
			else
				callback(album._id)

createFromId = (id) ->
	models.Album.findById id, (err, album) ->
		if err
			throw err
		else
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
		if album.topBreak.score < b.score
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


root = exports ? window
root.Album = Album
root.find = find
root.remove = remove
root.addBreak = addBreak
root.createFromId = createFromId
