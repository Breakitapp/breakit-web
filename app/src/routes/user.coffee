###
# Breakit Web app
# Routes for user creation and handling
# @authors
###
users = require '../models/userModel'
nconf = require 'nconf'


#This is used for creating test users through the browsers
exports.create = (req, res) ->
	console.log 'in create'
	console.log 'NODE_ENV: '+ nconf.get 'NODE_ENV'
	console.log 'db: '+ nconf.get 'database'

	res.send 'TESTING THE CONF: ' + nconf.get 'database'
	#res.render 'blocks/newUser', title : 'Create new Breakit user'

exports.submit = (req, res) ->
	console.log 'Data for new user received. Email: ' + req.body.em
	
	fn = req.body.fn
	ln = req.body.ln
	nn = req.body.nn
	em = req.body.em
	ph = req.body.ph
	
	#User class constructor only takes in nick and phone
	users.createUser nn, ph, (err, user) ->
		if err
			res.send('Error creating new user')
		else
			res.redirect('/users/' + user._id)

exports.view = (req,res) ->
	users.findById req.params.id, (err, targetUser) ->
		if not targetUser
			res.send('Did not find user.')
		else
			res.render 'blocks/viewUser', title : 'User ' + req.params.id, user: targetUser

exports.list = (req, res) ->
	users.list (userlist) ->
		if userlist == null
			res.send('No users found.')
		else
			res.render 'tests/userList', title : 'Breakit userlist', users: userlist

#this route should update users attributes but is broken
#TODO changeAttributes expects a JSON, gets a list of attr in stead
exports.update = (req,res) ->
	console.log 'Update on user data received. Id: ' + req.params.id
	
	users.changeAttributes req.params.id, req.body.fn, req.body.ln, req.body.nn, req.body.em, req.body.ph, req.body.token (err, user) ->		
		if err
			res.send('User updating failed.')
		else
			res.redirect('/users/' + user._id)

#Removes the user totally.
exports.remove = (req,res) ->
	users.remove req.params.id, (err) ->
		if err
			res.send('Removing user failed.')
		else
		  	res.send('User removed successfully.')
