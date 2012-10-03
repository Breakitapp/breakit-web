models = require './mongoModel'

class Comment
	constructor: (@comment, @user, @date = Date.now()) ->
		
root = exports ? window
root.Comment = Comment
		