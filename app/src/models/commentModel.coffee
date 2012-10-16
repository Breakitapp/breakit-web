models = require './mongoModel'

class Comment
	constructor: (@comment, @user) ->
		
root = exports ? window
root.Comment = Comment
		
