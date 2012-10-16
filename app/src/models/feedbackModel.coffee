models = require './mongoModel'

class Feedback
	constructor: (@user_id, @comment, @date) ->
	save: (callback) ->
		console.log 'hello'
		feedback_ = new models.Feedback
			user_id : @user_id
			comment : @comment
			date : @date
		console.log 'feedback: '+feedback_
		feedback_.save (err) ->
			if err
				console.log 'FEEDBACK: Feedback save failed'
				throw err
			else
				console.log 'FEEDBACK: Feedback saved successfully'
				callback null, feedback_

#EXPORT ALL THE FUNCTIONS HERE:

createIosFeedback = (reqBody, callback) ->
	console 'String from ios: '+ reqBody
	#Parse the string from ios

createFeedback = (reqBody, callback) ->
	console.log 'req.body.feedback' + reqBody.feedback
	console.log 'req.body.select_user' + reqBody.select_user
	
	fb_new = new Feedback(reqBody.select_user, reqBody.feedback)
	fb_new.save (err) ->
		callback err

list = (callback) ->
	models.Feedback.find().exec (err, data) ->
		if err
			console.log 'FEEDBACK: Failed to find any feedback.'
			callback null
		else
			feedback = (feedback for feedback in data)
			callback feedback


root = exports ? window
root.Feedback = Feedback
root.createFeedback = createFeedback
root.list = list
