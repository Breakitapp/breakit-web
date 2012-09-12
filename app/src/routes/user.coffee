user = require '../models/userModel' 

exports.create = (req, res) ->
	
	res.render 'newUser', title : 'Create new Breakit user'
	
exports.submit = (req, res) ->
	
	console.log 'Data for new user received. Email: ' + req.body.em
	
	fn = req.body.fn
	ln = req.body.ln
	nn = req.body.nn
	em = req.body.em
	ph = req.body.ph

	newUser = new user.User fn, ln, nn, em, ph
	newUser.save (err) ->
		if err
			res.send 'Error creating new user...'
			# redirect back and append the error message
		else
			res.send 'New user registered successfully!'
	
exports.view = (req,res) ->
	
	res.render 'viewUser', title : 'User ' + req.id, fn: 'pena'
	
exports.list = (req, res) ->

	user.list (users) ->
		
		console.log users
		res.render 'userlist', title : 'Breakit userlist', users: users
		
exports.update = (req,res) ->
	
exports.remove = (req,res) ->
	# delete userById req.id