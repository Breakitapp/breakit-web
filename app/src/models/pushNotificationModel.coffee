models = require './mongoModel'
users = require './userModel'
apns = require 'apn'


class PushNotification
	constructor: (@userId, @deviceToken, @date) ->
	save: (callback) ->
		@date = new Date()
		pushNotification_ = new models.PushNotification
			userId : @userId
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

options =
		cert: 'app/res/keys/BreakitDevServerCert.pem',                 # Certificate file path */
		certData: null,                   # String or Buffer containing certificate data, if supplied uses this instead of cert file path */
		key:  'app/res/keys/BreakitDevServerPrivateKey-noenc.pem',                  # Key file path */
		keyData: null,                    # String or Buffer containing key data, as certData */
		passphrase: null,                 # A passphrase for the Key file */
		ca: null,                         # String or Buffer of CA data to use for the TLS connection */
		pfx: null,	# File path for private key, certificate and CA certs in PFX or PKCS12 format. If supplied will be used instead of certificate and key above */
		pfxData: null,# PFX or PKCS12 format data containing the private key, certificate and CA certs. If supplied will be used instead of loading from disk. */
#		gateway: 'gateway.push.apple.com',# gateway address */
		gateway: 'gateway.sandbox.push.apple.com',# gateway address */
		port: 2195,                       # gateway port */
		rejectUnauthorized: true,         # Value of rejectUnauthorized property to be passed through to tls.connect() */
		enhanced: true,                   # enable enhanced format */
		errorCallback: (err, notification) ->
			if err
				console.log 'ERROR OCCURRED'
				console.log 'notification: '+notification
			else
				console.log 'IN ERROR CB, err=false'
		,         # Callback when error occurs function(err,notification) */
		cacheLength: 100,                  # Number of notifications to cache for error purposes */
		autoAdjustCache: true,            # Whether the cache should grow in response to messages being lost after errors. */
		connectionTimeout: 0              # The duration the socket should stay alive with no activity in milliseconds. 0 = Disabled. */

send = (userId, msgId, callback) ->
# Different type of messages have different ids
	users.findById userId, (err, user) ->
		if user is null
			console.log 'no user found'
			callback 'no user found', null
		else
			console.log 'success finding user'
			token = user.token
			apnsConnection = new apns.Connection options 
			console.log 'trying apns with token: ' + user.token
			console.log 'trying apns with token: ' + token
			myDevice = new apns.Device token
			note = new apns.Notification()
			note.expiry = Math.floor (Date.now() / 1000) + 3600 #Expires 1 hour from now.
			note.badge = 1
			note.sound = "ping.aiff"
			if msgId is 1
				note.alert = "Marko is infesting your phone"
			if msgId is 2
				note.alert = "You have a new message"
			note.payload = {'messageFrom': 'Marko'}
			note.device = myDevice
			console.log 'sending: '+ note
			apnsConnection.sendNotification note
			callback err, user

root = exports ? window
root.PushNotification = PushNotification
root.send = send
