models = require './mongoModel'

class Notification
	constructor: (@user_id_from, @user_id_to, @comment, @breakId) ->
	save: (callback) ->
		console.log 'in notifications constructor'
		@date = new Date()
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
			console.log 'saving as: from:'+from+', to: '+to+', comment: '+comment+', breakid: '+breakId
			new_notification = new Notification(from, to, comment, breakId)
			new_notification.save (err)->
				callback err
				
getNotifications = (userId, callback) ->
	models.Notification.find({'user_id_to' : userId}).sort({'date': 'ascending'}).exec (err, notifications) ->
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
