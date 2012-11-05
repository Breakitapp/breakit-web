models = require './mongoModel'

class User
	constructor: (@nName, @phone) ->
				
		@breaks = null
		
	saveToDB: (callback) ->
		user = new models.User
			nName : @nName
			phone : @phone
			
		user.save (err) ->
			if err
				console.log err
				callback err, null
			else
				console.log 'USER: Saved a new user: ' + user._id
				callback null, user

createUser = (nn, ph, callback) ->
	newUser = new User nn, ph
	newUser.saveToDB (err, user) ->
		callback err, user

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
getBreaks = (userId, page, callback) ->
	models.Break.find({'user' : userId}).sort({date: 'descending'}).skip(10*page).limit(10).exec (err, breaks) ->
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
			
changeAttributes = (json, callback) ->
# get user and continue from here
	console.log 'HERE !'
	console.log 'JSON: '+json
	console.log 'userId: '+json.userId

	if json.userId
		findById json.userId, (err, user) ->
			if err
				console.log 'Could not find user to be modified.'
				callback err
			else
				console.log 'Found user to be modified: ' + user.id
				console.log 'field: ' + json
				if json.fname
					user.fName = json.fname
					console.log 'changing fname'
				if json.lname
					user.lName = json.lname
					console.log 'changing lname'
				if json.nName
					console.log 'nname1: '+json.nName
					user.nName = json.nName
					console.log 'changing nname'
					console.log 'nname2: '+user.nName
					console.log 'changed nname'
				if json.email
					user.email = json.email
					console.log 'changing email'
				if json.phone
					user.phone = json.phone
					console.log 'changing phone'
				user.save (err) ->
					if err
						console.log 'USER: User save failed after trying to modify fields.'
						callback err, null
					else
						console.log 'USER: User modified successfully.'
						console.log 'USER nname: '+user.nName
						callback null, user
	else
		console.log 'No user found'
		callback null, null

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
root.getBreaks = getBreaks
