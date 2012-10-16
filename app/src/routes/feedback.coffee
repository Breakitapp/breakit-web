feedback = require '../models/feedbackModel'
userModel = require '../models/userModel'


exports.create = (req, res) ->
	users = userModel.list (u)->
		res.render 'feedback', title : 'Feedback test form', users: u
	
exports.iosCreate = (req, res) ->
	console.log 'HANDLING A REQUEST FROM IOS: ' + req.body
	feedback.createFeedback req.body, (err) ->
		if err
			console.log err
			res.send 'Error saving feedback'
		else
			console.log 'SUBMITTED'
			res.send 'SUCCESS'

exports.submit = (req, res) ->
	feedback.createFeedback req.body, (err) ->
		if err
			console.log err
			res.send 'Error saving feedback'
		else
			console.log 'SUBMITTED'
			res.send 'New Feedback SUBMITTED'

exports.list = (req, res) ->
	feedback.list (feedbacklist) ->
		if feedbacklist == null
			res.send('No feedback found.')
		else
			res.render 'feedbacklist', title : 'Breakit feedbacklist', feedbacks: feedbacklist
