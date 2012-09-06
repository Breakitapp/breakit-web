models = require './mongoModel'

class Break
	constructor: (@name) ->

	findAll: (callback) ->

	models.Break.find().sort({'date': 'descending'}).exec((err, breaks) ->
		#Errorhandling goes here //if err throw err
		breaks_ = (b for b in breaks)
		callback 'null', breaks_
		return breaks_
	)

root = exports ? window
root.Break = Break
