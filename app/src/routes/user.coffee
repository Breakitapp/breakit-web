async = require "async"
users = require '../models/userModel'
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

	users.createUser fn, ln, nn, em, ph, (err, id) ->
		if err
			res.send('Error creating new user')
		else
			res.redirect('/users/' + id)

###
	async.waterfall [

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
###
	
exports.view = (req,res) ->
		
	users.findById req.params.id, (err, targetUser) ->
		if err
			res.send('Did not find user.')
		else
			res.render 'viewUser', title : 'User ' + req.params.id, user: targetUser
    
exports.list = (req, res) ->

	users.list (userlist) ->
		if userlist == null
			res.send('No users found.')
		else
			res.render 'userlist', title : 'Breakit userlist', users: userlist
		
exports.update = (req,res) ->
	console.log 'Update on user data received. Id: ' + req.params.id
	
	users.changeAttributes req.params.id, req.body.fn, req.body.ln, req.body.nn, req.body.em, req.body.ph, (err, user) ->		

		if err
			res.send('User updating failed.')
		else
			res.redirect('/users/' + user._id)
		
exports.remove = (req,res) ->
	users.remove req.params.id, (err) ->
		if err
			res.send('Removing user failed.')
		else
		  	res.send('User removed successfully.')
		
			
		