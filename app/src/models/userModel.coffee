models = require './mongoModel'

class User
	constructor: (@id, @fName, @lName, @nName, @email, @phone) ->
		
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
				console.log err
				callback err
			else
				console.log 'Saved a new user: ' + user.id
				@dbid = user._id
				callback null
	
	addBreak: (break_) ->
		if typeof break_ is Break
			
			#Needs to access DB
			@breaks.push(break_)
			
		else
			throw 'this is not a break'
			
remove = (id, callback) ->
	@find id, (delUser) ->
		if delUser 
			console.log 'User to be deleted: ' + delUser.id
			delUser.remove (err) ->
				callback err
		else
			callback new Error 'No user found with that id'
			
changeAttribute = (id, newFName, newLName, newNName, newEmail, newPhone, callback) ->
		
	#Doesn't work if the user to be changed is not the first one in DB. mongoose gives duplicate value error.
		
	@find id, (editedUser) ->
		console.log 'User to be modified: ' + editedUser.id
		
		changedSomething = 0
													
		if editedUser.fName != newFName 
						
			changedSomething = 1
			models.User.update id: id, $set: {fName: newFName}, upsert: false, (err) ->
								
				if err
					console.log(err)
					console.log 'Failed to change first name for user ' + id
					callback err
				else
					console.log 'Changed first name for user ' + id
					callback null
					
		if editedUser.lName != newLName
			changedSomething = 1
			models.User.update id : id, $set : lName : newLName, upsert: false, (err) ->
				if err
					console.log 'Failed to change last name for user ' + id
					callback err
				else
					console.log 'Changed last name for user ' + id
					callback null	
		
		if editedUser.nName != newNName 
			changedSomething = 1
			models.User.update id : id, $set : nName : newNName, upsert: false, (err) ->
				if err
					console.log 'Failed to change nickname for user ' + id
					callback err
				else
					console.log 'Changed nickname for user ' + id
					callback null

		if editedUser.email != newEmail
			changedSomething = 1
			models.User.update id : id, $set : email : newEmail, upsert: false, (err) ->
				if err
					console.log 'Failed to change email for user ' + id
					callback err
				else
					console.log 'Changed email for user ' + id
					callback null		

		if editedUser.phone != newPhone
			changedSomething = 1
			models.User.update id : id, $set : phone : newPhone, upsert: false, (err) ->
				if err
					console.log 'Failed to change phone model for user ' + id
					callback err
				else
					console.log 'Changed phone model for user ' + id
					callback null
		
		if changedSomething == 0
			callback null 
			#Could differentiate the scenario where nothing was changed.
					
list = (callback) ->
	models.User.find().exec (err, data) ->

		if err
			throw err
		else
			users = (user for user in data)
			callback users
		
find = (id, callback) ->
	models.User.findOne(id : id).exec (err, foundUser) ->
		
		if err
			console.log 'Failed to find user: ' + id
			callback null	
		else
			console.log 'Found user: ' + foundUser.id
			callback foundUser

root = exports ? window
root.User = User
root.remove = remove
root.changeAttribute = changeAttribute
root.list = list
root.find = find
