#TODO refactoring. User creation doesn't seem like DRY

models	= require './mongoModel'
fs			= require 'fs'

class User
	constructor: (@nName, @phone, @token) ->
				
		@breaks = null
		
	saveToDB: (callback) ->
		user = new models.User
			nName : @nName
			phone : @phone
			token : @token
		user.save (err) ->
			if err
				console.log err
				callback err, null
			else
				console.log 'USER: Saved a new user: ' + user._id
				callback null, user

createUser = (nn, ph, token, callback) ->
	exports.validateUser nn, ph, (err)->
		if err
			console.log 'ERROR OR USER TAKEN'
			callback err, null
		else
			console.log 'success in validating user XX'
			console.log 'token: '+token
			newUser = new User nn, ph, token
			newUser.saveToDB (err, user) ->
				if err
					callback err, null
				else
					fs.mkdir './app/res/user/' + user.id, '0777', (err) ->
						fs.mkdir './app/res/user/' + user.id + '/images', '0777', (err) ->
					callback err, user

#What is the purpose of this function? Shouldn't we only validate the nickname in user creation? -E
validateUser = (nn, ph, callback) ->
		models.User.find({'nName': {$regex:'^(?i)'+nn+'$'}}).exec (err, data) ->
			if err
				console.log 'error in validate'
				# It shouldn't give an error in any case
				callback err
			else
				if data.length is 0
					console.log 'length is 0'
					console.log 'data: ' +data
					# NO USER FOUND... SAFE TO CREATE A NEW ONE
					callback null
				else
					console.log 'data length is: '+data.length
					console.log 'users are found'
					callback data.length+' users are found'


###TODO: CHANGE TO USE A MORE SCALABLE METHOD
It should be noted that searching with regex's case insensitive /i means that mongodb cannot search by index, so queries against large datasets can take a long time.
Even with small datasets, it's not very efficient. You take a far bigger cpu hit than your query warrants, which could become an issue if you are trying to achieve scale.
As an alternative, you can store an uppercase copy and search against that. For instance, I have a User table that has a username which is mixed case, but the id is an uppercase copy of the username. This ensures case-sensitive duplication is impossible (having both "Foo" and "foo" will not be allowed), and I can search by id = username.toUpperCase() to get a case-insensitive search for username.
If your field is large, such as a message body, duplicating data is probably not a good option. I believe using an extraneous indexer like Apache Lucene is the best option in that case.
check also the status of this: https://jira.mongodb.org/browse/SERVER-90
###


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
			
changeAttributes = (list, callback) ->
# get user and continue from here
	console.log 'in changeAttributes'
	console.log 'list: '+list
	console.log 'userId: '+list.userId
	console.log 'badge: '+list.badge

	if list.userId
		findById list.userId, (err, user) ->
			console.log 'badge inside findById: '+ list.badge
			if err
				console.log 'Could not find user to be modified.'
				callback err
			else
				console.log 'Found user to be modified: ' + user.id
				console.log 'field: ' + list
				if list.fname
					user.fName = list.fname
					console.log 'changing fname'
				if list.lname
					user.lName = list.lname
					console.log 'changing lname'
				if list.nName
					console.log 'nname1: '+list.nName
					user.nName = list.nName
					console.log 'changing nname'
					console.log 'nname2: '+user.nName
					console.log 'changed nname'
				if list.email
					user.email = list.email
					console.log 'changing email'
				if list.token
					user.token = list.token
					console.log 'changing token to: '+list.token
				if list.badge
					user.badge = list.badge
					console.log 'changing badge to: '+list.badge
				if list.phone
					user.phone = list.phone
					console.log 'changing phone'
				console.log 'going to user save now'
				user.save (err) ->
					if err
						console.log 'USER: User save failed after trying to modify fields.'
						callback err, null
					else
						console.log 'USER: User modified successfully.'
						console.log 'USER nname: '+user.nName
						console.log 'USER badge: '+user.badge
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
root.validateUser = validateUser
root.addBreak = addBreak
root.remove = remove
root.changeAttributes = changeAttributes
root.list = list
root.findById = findById
root.getBreaks = getBreaks
