models = require './mongoModel'
breakModel = require './breakModel'
async = require 'async'
_ = require 'underscore'

#TODO add location for album
class Album
	constructor: (@lon, @lat, @name, @breaks, @topBreak) ->

	saveToDB : (callback) ->
		album = new models.Album
			loc			:	{lon: @lon, lat: @lat}
			name		: @name
			breaks		:	@breaks
			topBreak	: @topBreak
		album.save (err) ->
			if err
				throw err
			else
				console.log 'ALBUM: created a new album ' + album.name + ' @ ' + album.loc
				callback album._id

###not needed?
createFromId = (id) ->
	models.Album.findById id, (err, album) ->
		if err
			throw err
		else
			newAlbum = new Album album.name, album.location, album.breaks
			return newAlbum
###

findByName = (name, callback) ->
	models.Album.findOne name: name, (err, foundAlbum) ->
		callback err, foundAlbum
			
findById = (id, callback) ->
	models.Album.findById(id).exec (err, foundAlbum) ->
		callback err, foundAlbum

list = (callback) ->
	console.log 'in list'
	findNear 24.83223594527063, 60.1802242005334, 0, (nullvalue, albums) ->
		console.log 'hello there'+albums
		console.log 'hello there nullv'+nullvalue
		callback albums
###
list = (callback) ->
	models.Album.find().exec (err, data) ->
		if err
			throw err
		else
			albums = (album for album in data)
			callback albums
###

#Finds albums relative to location and returns max 10 albums. Takes in location from the request in Album routes
findNear = (longitude, latitude, page, callback) ->
	albums = []
	#This is the geonear mongoose function, that searches for locationbased nodes in db
	models.Album.db.db.executeDbCommand {
		geoNear: 'albums' 
		near : [longitude, latitude]
		spherical : true
		}, (err, docs) ->
			if err
				throw err
			a = docs.documents[0].results
			console.log 'a:' + a
			console.log 'a[0]:' + a[0]
			if a[0]
				i = 0
				while a[page*10+i] and i < 10
					object = a[page*10+i]
					found_album = object.obj
					found_album.dis = object.dis
					albums.push found_album
					i++
			callback null, albums
	return albums
	
addBreak = (b) ->
	radius = 0.5/6353
	
	#always gives error -> RangeError: Maximum call stack size exceeded
	#models.Album.find({'loc' : {'$within' : {'$center' : [b.loc, radius]}}}).where('name').equals(b.location_name).exec((err, album) -> 
	
	models.Album.findOne(name: b.location_name).exec (err, album) -> 
		console.log 'SUPPLIES MUTHAFUCKA'
		
		if err
			console.log err
			throw err
		if album
			async.waterfall [
				(callback) ->
					console.log '1st in WF'
					
					album.breaks.push b._id
					album.save (err) ->
						if err
							throw err
						else
							needsUpdate = false
							b.album = album._id
					
							if (album.topBreak.points < b.points)
								b.top = true
								needsUpdate = true
					
							b.save (err) ->
								if err
									throw err
								else
									callback null, needsUpdate
									console.log needsUpdate
									console.log 'ALBUM: saved new break ' + b._id + ' to ' + album.name
				,
				(needsUpdate) ->
					console.log '2nd in WF'
					
					if needsUpdate
						updateTop album._id, b, (err) ->
							if err
								throw err
							else
								console.log 'jee'
			]
			
		else
			console.log 'ALBUM: Adding break ' + b.headline + ' and creating new album ' + b.location_name
			jsalbum = new Album b.loc.lon, b.loc.lat, b.location_name, [b._id], b
			jsalbum.saveToDB (albumId) ->
				b.album = albumId
				b.top = true		
				b.save (err) ->
					if err
						throw err

#Updates the top break for an album. Gets the new top break (can be same or different than the old top break). If the new top break is
#different it replaces the old one and the old one's 'top' parameter is changed to 'false'. If the new top break is the just an updated
#version of the old one, the top break field is simply updated.
updateTop = (id, b, callback) ->
	
	#Finding the album in question
	findById id, (err, a) ->	
		if err
			callback err
		else
			#Is the break the top break already?
			# -> Yes
			
			if String(b._id) == String(a.topBreak._id)
				console.log 'ALBUM: Updating old top break'
				
				a.topBreak = b
				console.log 'ALBUM: The old topbreak updated successfully in album: ' + a._id + ' top break: ' + a.topBreak._id
				a.save (err) ->
					if err
						callback err
					else
						console.log 'saved'
						callback null
			# -> No
			else
				console.log 'ALBUM: Replacing the top break'
			
				#the 'top' parameter of the old top break is changed to 'false' here.
				breakModel.findById a.topBreak._id, (err, oldTop) ->
					if err
						throw err
					else
						oldTop.top = false
						oldTop.save (err) ->
							if err
								callback err
							else
								#Switching to the new top break
								
								index = a.breaks.indexOf b._id
								a.breaks.splice index, 1, a.topBreak._id
								a.breaks[0] = b._id
								
								a.topBreak = b
																
								console.log 'ALBUM: New topbreak added successfully in album: ' + a._id + ' top break: ' + a.topBreak._id + ', headline: ' + a.topBreak.headline
								a.save (err) ->
									if err
										callback err
									else
										console.log 'saved'
										callback null
			

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

#Should return sorted breaks
#Not ready yet
findBreaks = (album, page, callback) ->
	models.Album.find({'_id': album}).sort({'points':'descending'}).exec((err, docs) ->
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
root.updateTop = updateTop
root.findByName = findByName
root.findById = findById
root.list = list
root.remove = remove
root.addBreak = addBreak
root.findBreaks = findBreaks
root.findNear = findNear
