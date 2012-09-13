async = require "async"
user = require '../models/userModel'
models = require '../models/mongoModel'

exports.create = (req, res) ->
	
	res.render 'newUser', title : 'Create new Breakit user'
	
exports.submit = (req, res) ->
	
	console.log 'Data for new user received. Email: ' + req.body.em
	
	fn = req.body.fn
	ln = req.body.ln
	nn = req.body.nn
	em = req.body.em
	ph = req.body.ph

	async.waterfall [
		
		#Counting id for the new user.
		#It would be nicer to perform this in constructor, but this creates some complications
		(callback) ->
			models.User.count {}, (err, c) ->
				id = c + 1
				console.log 'New user id assigned: ' + id
				callback null, id
		,
		(id, callback) ->
			newUser = new user.User fn, ln, nn, em, ph, id
			callback null, newUser
	], 
	(err, newUser) ->
		newUser.save (err) ->
			if err
				res.send 'Error creating new user'
			else
				res.send 'New user registered successfully!'
	
exports.view = (req,res) ->
		
	user.find req.params.id, (targetUser) ->
		res.render 'viewUser', title : 'User ' + req.params.id, user: targetUser
	#view also beta
	
exports.list = (req, res) ->

	user.list (users) ->
		
		res.render 'userlist', title : 'Breakit userlist', users: users
		
exports.update = (req,res) ->
	console.log 'Update on user data received. Id: ' + req.params.id
	
	user.find req.params.id, (editedUser) ->

		console.log 'Found the user to be updated: ' + editedUser.id
		
		changedSomething = 0
	
		if editedUser.fName != req.body.fn
			editedUser.changeAttribute 'fName', req.body.fn
			console.log 'Updated first name for user ' + editedUser.id
			changedSomething = 1
		if editedUser.lName != req.body.ln
			editedUser.changeAttribute 'lName', req.body.ln
			console.log 'Updated last name for user ' + editedUser.id
			changedSomething = 1
		if editedUser.nName != req.body.nn
			editedUser.changeAttribute 'nName', req.body.nn
			console.log 'Updated nickname for user ' + editedUser.id
			changedSomething = 1
		if editedUser.email != req.body.em
			editedUser.changeAttribute 'email', req.body.em
			console.log 'Updated email for user ' + editedUser.id
			changedSomething = 1
		if editedUser.phone != req.body.ph
			editedUser.changeAttribute 'phone', req.body.ph
			console.log 'Updated phone model for user ' + editedUser.id
			changedSomething = 1
			
		if changedSomething
			res.send('User updated successfully!')
		else
			res.send('Nothing changed.')
		
exports.remove = (req,res) ->
	# delete userById req.id