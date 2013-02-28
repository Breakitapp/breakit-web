apns = require 'apn'

options =
		cert: 'apns-prod-cert.pem',                 # Certificate file path */
		certData: null,                   # String or Buffer containing certificate data, if supplied uses this instead of cert file path */
		key:  'apns-prod-key-noenc.pem',                  # Key file path */
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
		errorCallback: undefined,         # Callback when error occurs function(err,notification) */
		cacheLength: 100,                  # Number of notifications to cache for error purposes */
		autoAdjustCache: true,            # Whether the cache should grow in response to messages being lost after errors. */
		connectionTimeout: 0              # The duration the socket should stay alive with no activity in milliseconds. 0 = Disabled. */

#Important: In a development environment you must set gateway to gateway.sandbox.push.apple.com.
#TODO: CHECK THAT
exports.send = (req, res)->
	token = 'bc5af2ab 910b4f45 1cc9b197 93136f33 88e10170 124dbeff 3409b9c1 cae57a91'
	apnsConnection = new apns.Connection options 
	myDevice = new apns.Device token
	note = new apns.Notification()
	note.expiry = Math.floor (Date.now() / 1000) + 3600 #Expires 1 hour from now.
	note.badge = 3
	note.sound = "ping.aiff"
	note.alert = "You have a new message"
	note.payload = {'messageFrom': 'Caroline'}
	note.device = myDevice
	apnsConnection.sendNotification note
	res.send 'success?'
###
N.B.: If you wish to send notifications containing emoji or other multi-byte characters you will need to set 
note.encoding = 'ucs2'. This tells node to send the message with 16bit characters, however it also means your 
message payload will be limited to 127 characters.
###
