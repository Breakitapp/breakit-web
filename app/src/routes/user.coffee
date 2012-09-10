user = require '../models/userModel' 

exports.create = (req, res) ->
	
	res.render 'user', title : 'Create new Breakit user'
	
exports.submit = (req, res) ->
	
	#FIX
	
	fn = req.body.fn
	ln = req.body.ln
	nn = req.body.nn
	em = req.body.em
	ph = req.body.ph

	newUser = new user.User fn, ln, nn, em, ph
	newUser.save()