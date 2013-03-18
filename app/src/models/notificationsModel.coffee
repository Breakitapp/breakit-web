models = require './mongoModel'
pushNotifications = require './pushNotificationModel'

class Notification
	constructor: (@user_id_from, @user_id_to, @comment, @breakId, @type) ->
	save: (callback) ->
		console.log 'in notifications constructor'
		@date = new Date()
		notification_ = new models.Notification			
			user_id_from : @user_id_from
			user_id_to : @user_id_to
			comment : @comment
			breakId : @breakId
			date : @date
			type : @type
		console.log 'notification: '+notification_
		notification_.save (err) ->
			if err
				console.log 'Notification: Notification save failed'
				throw err
			else
				console.log 'Notification: Notification saved successfully'
				callback null, notification_
				
createNotification = (from, to, comment, breakId, type, callback) ->
	if to is '5110eff913e66edb527cb501'
		console.log 'web interface comment by prod anonymous user to be ignored'
		callback 'ignore web comment by prod'
	else if to is '50a369413268496061000002'
		console.log 'web interface comment by dev anonymous user to be ignored'
		callback 'ignore web comment by dev'
	else
		pushNotifications.send to, 1, (err, user)->
			if err
				console.log 'ERROR specifics. User to send: '+to+'err:' +err+' user: '+user
				console.log 'ERROR in sending push notification'
			else
				console.log 'sent push notification to user: '+user.nName
		console.log 'saving as: from:'+from+', to: '+to+', comment: '+comment+', breakid: '+breakId+'type: '+type
		new_notification = new Notification(from, to, comment, breakId, type)
		new_notification.save (err)->
			callback err

getNotifications = (userId, callback) ->
	models.Notification.find({'user_id_to' : userId}).sort({'date': 'ascending'}).exec (err, notifications) ->
		if err
			callback err, null
		else
			pushNotifications.changeBadge userId, 0, (err)->
				if err
					console.log 'ERROR IN SETTING THE BADGE TO 0'
					callback 'error from change Badge: '+err
				else
					console.log 'SUCCESS IN SETTING THE BADGE to 0 in getNotifications'
					#console.log 'notifications: ' + notifications
					callback null, notifications
					return notifications
	
root = exports ? window
root.Notification = Notification
root.createNotification = createNotification
root.getNotifications = getNotifications
