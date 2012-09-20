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
			newUser = new user.User id, fn, ln, nn, em, ph
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
	#TODO: view also beta value (in jade)
	
exports.list = (req, res) ->

	user.list (users) ->
		
		res.render 'userlist', title : 'Breakit userlist', users: users
		
exports.update = (req,res) ->
	console.log 'Update on user data received. Id: ' + req.params.id
	
	user.changeAttribute req.params.id, req.body.fn, req.body.ln, req.body.nn, req.body.em, req.body.ph, (err) ->		

		if err
			res.send('User updating failed.')
		else
			res.send('User updated successfully!')
		
exports.remove = (req,res) ->
	user.remove req.params.id, (err) ->
		if err
			res.send('Removing user failed.')
		else
		  	res.send('User removed successfully.')
		
			
		