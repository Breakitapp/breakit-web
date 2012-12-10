feedback = require '../models/feedbackModel'
userModel = require '../models/userModel'


exports.create = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		users = userModel.list (u)->
			res.render 'feedback', title : 'Feedback test form', users: u
	
exports.submit = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		feedback.createWebFeedback req.body, (err) ->
			if err
				console.log err
				res.send 'Error saving feedback'
			else
				res.send 'New Feedback SUBMITTED'

exports.list = (req, res) ->
	if(req.ip isnt '54.247.69.189')
		feedback.list (feedbacklist) ->
			if feedbacklist == null
				res.send('No feedback found.')
			else
				res.render 'feedbacklist', title : 'Breakit feedbacklist', feedbacks: feedbacklist
