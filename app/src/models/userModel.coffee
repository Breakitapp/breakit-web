models = require './mongoModel'

class User
	constructor: (@fName, @lName, @nName, @email, @phone) ->
		
		#Testing if email is in a valid format?
		
		@breaks = null
		
	save: (callback) ->
		user = new models.User
			fName : @fName
			lName : @lName
			nName : @nName
			email : @email
			phone : @phone
		user.save (err) ->
			if err
				callback(err)
				throw err
			else
				console.log 'saved a new user ' + @nName
	
	remove: () ->
		
	
	addBreak: (break_) ->
		if typeof break_ is Break
			@breaks.push(break_)
		else
			throw 'this is not a break'
			
	changeAttribute: (toBeChanged, newValue) ->
		
		if toBeChanged is 'fName' 
			if typeof newValue is String then fName = newValue
			else throw 'fName must be a String'
			
		else if toBeChanged is 'lName' 
			if typeof newValue is String then lName = newValue
			else throw 'lName must be a String'
			
		else if toBeChanged is 'nName' 
			if typeof newValue is String then nName = newValue
			else throw 'nName must be a String'
			
		else if toBeChanged is 'email' 
			if typeof newValue is String then email = newValue
				
				#Testing if email is in a valid format?
				
			else throw 'Invalid email format'	
			
		else if toBeChanged is 'phone'
			if typeof newValue is String then phone = newValue
			else throw 'Invalid phone model format'
			
		else if toBeChanged is 'beta'
			if typeof newValue is Boolean then beta = newValue
			else throw 'Beta value must be Boolean'
				
		else throw 'No such attribute #{toBeChanged}'
				
				
list = (callback) ->
	models.User.find().exec (err, data) ->

		#Error handling?

		users = (user for user in data)
		callback users

root = exports ? window
root.User = User
root.list = list
