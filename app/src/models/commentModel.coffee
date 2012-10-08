models = require './mongoModel'

class Comment
	constructor: (@comment, @user, @date) ->
		
root = exports ? window
root.Comment = Comment
		
