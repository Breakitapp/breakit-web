models = require './mongoModel'

class Comment
	constructor: (@comment, @user) ->
		@date = new Date()
		console.log @date + ': CREATED A NEW COMMENT: '+ @comment
		
root = exports ? window
root.Comment = Comment
		
