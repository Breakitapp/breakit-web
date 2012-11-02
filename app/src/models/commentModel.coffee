models = require './mongoModel'
users = require './userModel'

class Comment
	constructor: (@comment, @user, @usernick) ->
		@date = new Date()		
		console.log @date + ': CREATED A NEW COMMENT: '+ @comment
		
root = exports ? window
root.Comment = Comment
		
