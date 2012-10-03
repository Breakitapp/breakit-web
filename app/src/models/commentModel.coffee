models = require './mongoModel'

class Comment
	constructor: (@comment, @user, @date = Date.now()) ->
		
	###
	save: (callback) ->
		newComment = new models.Comment
			comment : @comment
			user : @user
			date : @date
			
		newComment.save (err) ->
			if err 
				console.log 'COMMENT: Comment save failed'
				throw err
			else
				console.log 'COMMENT: Comment saved successfully.'
				callback null, newComment
	###	
		
root = exports ? window
root.Comment = Comment
		