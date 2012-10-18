models = require './mongoModel'

class User
	constructor: (@fName, @lName, @nName, @email, @phone) ->
				
		@breaks = null
		
	saveToDB: (callback) ->
		user = new models.User
			fName : @fName
			lName : @lName
			nName : @nName
			email : @email
			phone : @phone
			
		user.save (err) ->
			if err
				console.log err
				callback err, null
			else
				console.log 'USER: Saved a new user: ' + user._id
				callback null, user._id

createUser = (fn, ln, nn, em, ph, callback) ->
	newUser = new User fn, ln, nn, em, ph
	newUser.saveToDB (err, id) ->
		callback err, id

addBreak = (userId, break_, callback) ->
	if typeof break_ is Break
		
		findById userId (err, user) ->
			if err
				callback err, null
			else
				user.breaks.push break_
				user.saveToDB (err, savedUser) ->
					if err
						console.log 'USER: User save failed after new break.'
						callback err, null					
					else
						console.log 'USER: User saved after new break.'
						callback null, savedUser
						
	else
		throw 'USER: What you tried to add is not a break'

#Find breaks by a single user (for the "my breaks" view)
findBreaks = (userId, page, callback) ->
	models.Break.find({'user' : userId}).skip(10*(page-1)).limit(10).exec(err, breaks) ->
		if err
			callback err, null
		else
			breaks_ = (b for b in breaks)
			callback null, breaks_
			return breaks_
			
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
			user.saveToDB (err, modifiedUser) ->
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
			callback users
		
findById = (userId, callback) ->
	models.User.findById(userId).exec (err, foundUser) ->
		callback err, foundUser

root = exports ? window
root.User = User
root.createUser = createUser
root.addBreak = addBreak
root.remove = remove
root.changeAttributes = changeAttributes
root.list = list
root.findById = findById
