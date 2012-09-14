models = require './mongoModel'

class Album
	constructor: (@name, @location = [60.188289, 24.83739]) ->
		addBreak : (b) ->
