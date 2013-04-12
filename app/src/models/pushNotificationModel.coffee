models = require './mongoModel'
users = require './userModel'
apns = require 'apn'
nconf = require 'nconf'


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

optionsDev =
	cert: 'app/res/keys/BreakitDevServerCert.pem',                 # Certificate file path */
	certData: null,                   # String or Buffer containing certificate data, if supplied uses this instead of cert file path */
	key:  'app/res/keys/BreakitDevServerPrivateKey-noenc.pem',                  # Key file path */
	keyData: null,                    # String or Buffer containing key data, as certData */
	passphrase: null,                 # A passphrase for the Key file */
	ca: null,                         # String or Buffer of CA data to use for the TLS connection */
	pfx: null,	# File path for private key, certificate and CA certs in PFX or PKCS12 format. If supplied will be used instead of certificate and key above */
	pfxData: null,# PFX or PKCS12 format data containing the private key, certificate and CA certs. If supplied will be used instead of loading from disk. */
#		gateway: 'gateway.push.apple.com',# gateway address */
	gateway: 'gateway.sandbox.push.apple.com', # gateway address */
	port: 2195,                       # gateway port */
	rejectUnauthorized: true,         # Value of rejectUnauthorized property to be passed through to tls.connect() */
	enhanced: true,                   # enable enhanced format */
	errorCallback: (err, notification) ->
		if err
			console.log 'ERROR OCCURRED IN THE CALLBACK FROM APNS'
			console.log 'notification: '+notification
		else
			console.log 'IN ERROR CB, err=false'
	,         # Callback when error occurs function(err,notification) */
	cacheLength: 100,                  # Number of notifications to cache for error purposes */
	autoAdjustCache: true,            # Whether the cache should grow in response to messages being lost after errors. */
	connectionTimeout: 0              # The duration the socket should stay alive with no activity in milliseconds. 0 = Disabled. */

optionsProd =
	cert: 'app/res/keys/BreakitProdServerCert.pem',                 # Certificate file path */
	certData: null,                   # String or Buffer containing certificate data, if supplied uses this instead of cert file path */
	key:  'app/res/keys/BreakitProdServerPrivateKey-noenc.pem',                  # Key file path */
	keyData: null,                    # String or Buffer containing key data, as certData */
	passphrase: null,                 # A passphrase for the Key file */
	ca: null,                         # String or Buffer of CA data to use for the TLS connection */
	pfx: null,	# File path for private key, certificate and CA certs in PFX or PKCS12 format. If supplied will be used instead of certificate and key above */
	pfxData: null,# PFX or PKCS12 format data containing the private key, certificate and CA certs. If supplied will be used instead of loading from disk. */
#		gateway: 'gateway.push.apple.com',# gateway address */
	gateway: 'gateway.push.apple.com',# gateway address */
	port: 2195,                       # gateway port */
	rejectUnauthorized: true,         # Value of rejectUnauthorized property to be passed through to tls.connect() */
	enhanced: true,                   # enable enhanced format */
	errorCallback: (err, notification) ->
		if err
			console.log 'ERROR OCCURRED IN THE CALLBACK FROM APNS'
			console.log 'ERROR: '+err
		else
			console.log 'IN ERROR CB, err=false'
	,         # Callback when error occurs function(err,notification) */
	cacheLength: 100,                  # Number of notifications to cache for error purposes */
	autoAdjustCache: true,            # Whether the cache should grow in response to messages being lost after errors. */
	connectionTimeout: 0              # The duration the socket should stay alive with no activity in milliseconds. 0 = Disabled. */

send = (userId, msgId, callback) ->
	console.log 'SENDING PUSH NOTIFICATION'
	console.log 'userId: '+userId
	
	exports.changeBadge userId, 1, (err)->
		console.log 'sending PUSH notification'
		if err
			console.log 'ERROR IN SETTING THE BADGE'
			callback 'error from change Badge: '+err
		else
			console.log 'SUCCESS IN SETTING THE BADGE'
			console.log 'looking for the user to receive push N.'
			users.findById userId, (err, user) ->
				if user is null
					console.log 'no user found'
					callback 'no user found', null
				else if user.token
					console.log 'success finding user'
					console.log 'found user: '+user.nName
					token = user.token
					console.log 'ENVIRONMENT: ' + nconf.get 'NODE_ENV'
					if nconf.get('NODE_ENV') is 'local'
						console.log 'ENVIRONMENT RECOGNIZED AS loCAL'
					if nconf.get('NODE_ENV') is 'development'
						console.log 'ENVIRONMENT RECOGNIZED AS DEV'
						apnsConnection = new apns.Connection optionsProd
						#TESTING prod certificates
						#apnsConnection = new apns.Connection optionsProd
					if nconf.get('NODE_ENV') is 'production'
						apnsConnection = new apns.Connection optionsProd 
						console.log 'ENVIRONMENT RECOGNIZED AS PROD'
					console.log 'trying apns with token: ' + token
					myDevice = new apns.Device token
					note = new apns.Notification()
					note.expiry = Math.floor (Date.now() / 1000) + 3600 #Expires 1 hour from now.
					note.badge = user.badge
					note.sound = "ping.aiff"
					if msgId is 1
						note.alert = "You just received a new notification"
					note.payload = {'messageFrom': 'Marko'}
					note.device = myDevice
					console.log 'sending: '+ note.payload
					apnsConnection.sendNotification note
					callback err, user
					return
				else 
					console.log 'RECEIVING USER TOKEN IS NOT SET'
					console.log 'SKIP THIS USER'
					callback 'user has no token', user

changeBadge = (userId, increment, callback) ->
# finding user to get the existing badge count
	users.findById userId, (err, user) ->
		if user is null
			console.log 'no user found'
			callback 'no user found', null
		else
			console.log 'success finding user'
			console.log 'found user: '+user.nName
			console.log 'user badge: '+user.badge
			badge = (user.badge + increment)
			if increment is 0
				badge = 0
			console.log 'user new badge: '+badge
			list = {}
			list['userId'] = userId
			list['badge'] = badge
			console.log 'user new badge: ' + badge
			users.changeAttributes list, (err) ->
				console.log 'user new badge: ' + badge
				console.log 'changing attributes'
				if err
					console.log 'ERROR IN SETTING THE BADGE'
					callback 'error'
				else
					console.log 'SUCCESS IN SETTING THE BADGE to'+badge+'in changing attributes'
					callback null

root = exports ? window
root.PushNotification = PushNotification
root.send = send
root.changeBadge = changeBadge
