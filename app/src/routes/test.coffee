breaks	= require '../models/breakModel'
albums	= require '../models/albumModel'
comments = require '../models/commentModel'
users = require '../models/userModel'
feedback = require '../models/feedbackModel'

exports.index = (req, res) ->
	res.send 'This route is used for testing stuff'
	

exports.sendForm= (req, res) ->
	if(req.ip isnt '54.247.69.189')
		res.render 'test_templates/testform', title : 'Test sending a form to server'

exports.submitForm= (req, res) ->
	if(req.ip isnt '54.247.69.189')
		test = req.body.key1
		console.log req.body
		res.send 'Key1: '+test

exports.specifyFeed = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		res.render 'specifyFeed', title : 'Specify the information for album feed'

exports.feed = (req, res) ->
	if(req.ip isnt '54.247.69.189')
			users.getBreaks req.body.userId, req.body.page, (err, breaks) ->
				if err
					throw err
				else
					console.log breaks
					console.log breaks.length
					res.redirect '/test/userfeed'
