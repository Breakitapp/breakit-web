models = require './mongoModel'

class PushNotification
	constructor: (@userId, @deviceToken, @date) ->
	save: (callback) ->
		@date = new Date()
		feedback_ = new models.pushNotification
			userId : @user_id
			deviceToken : @deviceToken
			date : @date
		console.log 'push notification: ' + pushNotification_
		pushNotification_.save (err) ->
			if err
				console.log 'Push notification save failed'
				throw err
			else
				console.log 'Push notification saved successfully'
				callback null, pushNotification_

store = (userId, deviceToken, callback) ->
		pushNotification = new PushNotification userId, deviceToken
		pushNotification.save (err) ->
			callback err
