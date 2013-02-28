fs = require 'fs'
crypto = require 'crypto'
tls = require 'tls'

#TODO: FIX THE PATH TO THE KEY FileS ON SERvER
certPem = fs.readFileSync 'apns-prod-cert.pem', encoding='ascii'
keyPem = fs.readFileSync 'apns-prod-key-noenc.pem', encoding='ascii'
caCert = fs.readFileSync 'apple-worldwide-certificate-authority.cer', encoding='ascii'
options = { key: keyPem, cert: certPem, ca: [ caCert ] }

pushnd = { aps: { alert:'This is a test' }}
hextoken = 'bc5af2ab 910b4f45 1cc9b197 93136f33 88e10170 124dbeff 3409b9c1 cae57a91' # Push token from iPhone app. 32 bytes as hexadecimal string

exports.connectAPN = (next) ->
	stream = tls.connect 2195, 'gateway.sandbox.push.apple.com', options, ()->
		# connected
		next !stream.authorized, stream

exports.hextobin = (hexstr) ->
		buf = new Buffer hexstr.length / 2
		for [0...hexstr.length/2]
			buf[_i] = parseInt hexstr[_i * 2], 16 << 4 + parseInt hexstr[_i * 2 + 1], 16
		return buf 

exports.push = ()->
	payload = JSON.stringify pushnd
	payloadlen = Buffer.byteLength payload, 'utf-8'
	tokenlen = 32
	buffer = new Buffer 1 +  4 + 4 + 2 + tokenlen + 2 + payloadlen
	i = 0
	buffer[i++] = 1 #command
	msgid = 0xbeefcace # message identifier, can be left 0
	buffer[i++] = msgid >> 24 & 0xFF
	buffer[i++] = msgid >> 16 & 0xFF
	buffer[i++] = msgid >> 8 & 0xFF
	buffer[i++] = msgid & 0xFF
	
	# expiry in epoch seconds (1 hour)
	seconds = Math.round new Date().getTime() / 1000 + 1*60*60
	buffer[i++] = seconds >> 24 & 0xFF
	buffer[i++] = seconds >> 16 & 0xFF
	buffer[i++] = seconds >> 8 & 0xFF
	buffer[i++] = seconds & 0xFF
	
	buffer[i++] = tokenlen >> 8 & 0xFF # token length
	buffer[i++] = tokenlen & 0xFF
	token = hextobin hextoken
	token.copy buffer, i, 0, tokenlen
	i += tokenlen
	buffer[i++] = payloadlen >> 8 & 0xFF # payload length
	buffer[i++] = payloadlen & 0xFF
	
	payload = Buffer payload
	payload.copy buffer, i, 0, payloadlen
	
	stream.write buffer # write push notification
