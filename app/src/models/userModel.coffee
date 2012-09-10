models = require './mongoModel'

class User
	constructor: (@fName, @lName, @nName, @email, @phone) ->
		@breaks = null
		
	save: ->
		user = new models.User
			fName : @fName
			lName : @lName
			nName : @nName
			email : @email
			phone : @phone
		user.save (err) ->
			if err
				throw error
			else
				console.log 'saved a new user #{nName}'
	
	addBreak: (break_) ->
		if typeof break_ is Break
			@breaks.push(break_)
		else
			throw 'this is not a break'
				
	#find: -> 
	
###
	comment (Comment, Break)
	
	addBreak (Break)
	###
	



root = exports ? window
root.User = User
