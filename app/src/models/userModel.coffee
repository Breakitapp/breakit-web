models = require './mongoModel'

class User
	constructor: (@fName, @lName, @nName, @email, @phone) ->
				
		@breaks = null
		
	save: (callback) ->
		user = new models.User
			fName : @fName
			lName : @lName
			nName : @nName
			email : @email
			phone : @phone
		console.log 'new user created'+user
		console.log 'saving user'
		user.save (err) ->
			console.log 'user saved'
			if err
				console.log err
				callback err, null
			else
				console.log 'USER: Saved a new user: ' + user._id
				callback null, user
	
addBreak = (userId, break_, callback) ->
	if typeof break_ is Break
		
		findById userId (err, user) ->
			if err
				callback err, null
			else
				user.breaks.push break_
				user.save (err, savedUser) ->
					if err
						console.log 'USER: User save failed after new break.'
						callback err, null					
					else
						console.log 'USER: User saved after new break.'
						callback null, savedUser
						
	else
		throw 'USER: What you tried to add is not a break'
			
remove = (userId, callback) ->
	findById userId, (err, user) ->
		if err
			console.log 'Could not find user to be deleted.'
			callback err
		else 
			console.log 'User to be deleted: ' + user.id
			user.remove (err) ->
				callback err
			
changeAttributes = (userId, newFName, newLName, newNName, newEmail, newPhone, callback) ->
				
	findById userId, (err, user) ->
		if err
			console.log 'Could not find user to be modified.'
			callback err
		else
			console.log 'Found user to be modified: ' + user.id
			user.fName = newFName
			user.lName = newLName
			user.nName = newNName
			user.email = newEmail
			user.phone = newPhone
			user.save (err, modifiedUser) ->
				if err
					console.log 'USER: User save failed after trying to modify fields.'
					callback err, null
				else
					console.log 'USER: User modified successfully.'
					callback null, modifiedUser
					
list = (callback) ->
	models.User.find().exec (err, data) ->

		if err
			console.log 'USER: Failed to find any users.'
			callback null
		else
			users = (user for user in data)
			console.log 'USER: users -' + users
			callback users
		
findById = (userId, callback) ->
	models.User.findById(userId).exec (err, foundUser) ->
		callback err, foundUser

root = exports ? window
root.User = User
root.addBreak = addBreak
root.remove = remove
root.changeAttributes = changeAttributes
root.list = list
root.findById = findById
