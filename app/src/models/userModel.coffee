models = require './mongoModel'

class User
	constructor: (@fName, @lName, @nName, @email, @phone, @id) ->
		
		#Testing if email is in a valid format?
		
		@breaks = null
		
		###
		It would be nicer to count id inside the constructor, 
		but this creates some problems...
		
		models.User.count {}, (err, c) ->
			if err
				throw err
			else
				@id = c + 1
				console.log 'New user id assigned: ' + @id
				
		###
		
	save: (callback) ->
		user = new models.User
			id : @id
			fName : @fName
			lName : @lName
			nName : @nName
			email : @email
			phone : @phone
		user.save (err) ->
			if err
				callback err
			else
				console.log 'Saved a new user: ' + @email
				callback null
	
	remove: (id, callback) ->
		models.User.findOne id: id, (err, user) ->
			if err
				callback err
			else if user 
				user.remove (err) ->
					callback err
			else
				callback new Error 'No user found with that id'
	
	addBreak: (break_) ->
		if typeof break_ is Break
			@breaks.push(break_)
		else
			throw 'this is not a break'
			
	changeAttribute: (toBeChanged, newValue) ->
		
		#Not working?
		
		if toBeChanged is 'fName' 
			if typeof newValue is String then @fName = newValue
			else throw 'fName must be a String'
			
		else if toBeChanged is 'lName' 
			if typeof newValue is String then @lName = newValue
			else throw 'lName must be a String'
			
		else if toBeChanged is 'nName' 
			if typeof newValue is String then @nName = newValue
			else throw 'nName must be a String'
			
		else if toBeChanged is 'email' 
			if typeof newValue is String then @email = newValue
				
				#Testing if email is in a valid format?
				
			else throw 'Invalid email format'	
			
		else if toBeChanged is 'phone'
			if typeof newValue is String then @phone = newValue
			else throw 'Invalid phone model format'
			
		else if toBeChanged is 'beta'
			if typeof newValue is Boolean then @beta = newValue
			else throw 'Beta value must be Boolean'
				
		else throw 'No such attribute #{toBeChanged}'
				
list = (callback) ->
	models.User.find().exec (err, data) ->

		if err
			callback err
		else
			users = (user for user in data)
			callback users
		
find = (id, callback) ->
	models.User.findOne(id : id).exec (err, foundUser) ->
		
		if err
			callback err	
		else
			callback foundUser

root = exports ? window
root.User = User
root.list = list
root.find = find
