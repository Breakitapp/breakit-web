feedback = require '../models/feedbackModel'
userModel = require '../models/userModel'

exports.login = (req, res) ->

	res.render 'adminlogin_feedback', title: 'Breakit admin login'

exports.create = (req, res) ->
	users = userModel.list (u)->
		res.render 'feedbackForm', title : 'Feedback test form', users: u
	
exports.submit = (req, res) ->
	feedback.createWebFeedback req.body, (err) ->
		if err
			console.log err
			res.send 'Error saving feedback'
		else
			res.send 'New Feedback SUBMITTED'

exports.view = (req, res) ->
	
	if String(req.body.admincode) is "d0lph1n" #hardcoded password atm. TODO: make the admin authentication properly
	
		feedback.list (feedbacklist) ->
			if feedbacklist == null
				res.send('No feedback found.')
			else
				res.render 'feedbacklist', title : 'Breakit feedbacklist', feedbacks: feedbacklist
				
	else
		res.redirect('/feedback/')
