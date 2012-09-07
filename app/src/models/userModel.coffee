models = require './mongoModel'

class User
	constructor: (@fName, @lName, @nName, @email, @phone) ->
		
		#Testing if email is in a valid format?
		
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
			
	changeAttribute: (toBeChanged, newValue) ->
		
		if toBeChanged is 'fName' 
			if typeof newValue is String
				then fName = newValue
			else throw 'fName must be a String'
			
		else if toBeChanged is 'lName' 
			if typeof newValue is String
				then lName = newValue
			else throw 'lName must be a String'
			
		else if toBeChanged is 'nName' 
			if typeof newValue is String
				then nName = newValue
			else throw 'nName must be a String'
			
		else if toBeChanged is 'email' 
			if typeof newValue is String
				
				#Testing if email is in a valid format?
				
				then email = newValue
			else throw 'Invalid email format'	
			
		# TODO: OTHER ATTRIBUTE OPTIONS
		
		else throw 'No such attribute #{toBeChanged}'
				
	#find: -> 
	
	



root = exports ? window
root.User = User