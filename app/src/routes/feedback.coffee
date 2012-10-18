feedback = require '../models/feedbackModel'
userModel = require '../models/userModel'


exports.create = (req, res) ->
	users = userModel.list (u)->
		res.render 'feedback', title : 'Feedback test form', users: u
	
exports.submit = (req, res) ->

	feedback.createWebFeedback req.body, (err) ->
		if err
			console.log err
			res.send 'Error saving feedback'
		else
			res.send 'New Feedback SUBMITTED (ios)'

exports.list = (req, res) ->
	feedback.list (feedbacklist) ->
		if feedbacklist == null
			res.send('No feedback found.')
		else
			res.render 'feedbacklist', title : 'Breakit feedbacklist', feedbacks: feedbacklist
