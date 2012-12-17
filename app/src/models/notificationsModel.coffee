models = require './mongoModel'

class Notification
	constructor: (@user_id_from, @user_id_to, @comment, @breakid, @date) ->
	save: (callback) ->
		console.log 'in notifications constructor'
		notification_ = new models.Notification
			user_id_from : @user_id_from
			user_id_to : @user_id_to
			comment : @comment
			breakId : @breakId
			date : @date
		console.log 'notification: '+notification_
		notification_.save (err) ->
			if err
				console.log 'Notification: Notification save failed'
				throw err
			else
				console.log 'Notification: Notification saved successfully'
				callback null, notification_
				
createNotification = (from, to, comment, breakId, callback) ->
			new_notification = new Notification(from, to, comment, breakId)
			new_notification.save (err)->
				callback err
				
getNotifications = (userId, callback) ->
	models.Notification.find({'user_id_to' : userId}).sort({'date': 'descending'}).exec (err, notifications) ->
		if err
			callback err, null
		else
			console.log 'notifications: ' + notifications
			callback null, notifications
			return notifications
	
root = exports ? window
root.Notification = Notification
root.createNotification = createNotification
root.getNotifications = getNotifications