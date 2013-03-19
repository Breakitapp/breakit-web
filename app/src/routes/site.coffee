###
# Breakit Web app
# Routes for the site
# Author: Mikko Majuri
###

models = require '../models/mongoModel'
mailer = require 'nodemailer'
breaks = require '../models/breakModel'
users = require '../models/userModel'
comments = require '../models/commentModel'
albums = require '../models/albumModel'


exports.public = (req, res) ->
	fromMedia = false
	console.log 'LOGGING TO public'
	console.log 'req.params.user: '+req.params.user
	console.log 'TESTING BETTER WAY: req.params.media: '+req.params.media
	console.log 'req.params.admincode: '+req.params.admincode
	console.log 'req.body.id: (breakId)'+req.params.id
	if(req.params.admincode is 'd0lph1n')
		console.log 'GOES TO IF'
	else
		console.log 'GOES NOT'
	#created a default value for checkMediaInterface variable to be false
	###
		checkMediaInterface = false
		#parses the querystring if there is one
		queryObject = require('url').parse(req.url,true).query
		#TODO checks the last visited url. IF the last visited url is media interface changes checkMediaInterface value to true
		getLastVisitedUrl = req.header('Referer')
		console.log 'TESTING XXXXXX - last visited url: ' + getLastVisitedUrl
		if getLastVisitedUrl?
			splitUrl = getLastVisitedUrl.split('/')
			getLastVisitedUrl = splitUrl[splitUrl.length-1]
			console.log 'TESTING XXXXXX - last visited url: ' + getLastVisitedUrl
			if getLastVisitedUrl is 'media' 
				#While checkMediaInterface is true it allows the mediainterface button to appear in onepager
				checkMediaInterface = true
				console.log checkMediaInterface
			#Check if commented has happened while being marked on media interface
			else if queryObject.name is 'media'
					checkMediaInterface = true
	###
	if req.params.media is 'true'
		fromMedia = true
		
	cookieName = ''
	cookieValue = ''
	cookies = {}
	req.headers.cookie && req.headers.cookie.split(';').forEach (cookie) ->
		parts = cookie.split '='
		checkCookie = cookies[parts[0].trim()] = (parts[0] || '').trim()
		console.log checkCookie
		if checkCookie is 'breakit'
			cookieName = cookies[parts[0].trim()] = (parts[0] || '').trim()
			cookieValue = cookies[parts[0].trim()] = (parts[1] || '').trim()
			console.log 'cookie ' + cookieName + ' with value ' + cookieValue + ' is now set!'
	console.log 'name: ' + cookieName
	console.log 'value: ' + cookieValue
	console.log 'id: ' + req.params.id 
	if cookieName is 'breakit' and cookieValue is req.params.id
		breaks.findById req.params.id, (err, break_) ->
			if err
				res.send '404'
			else
				#console.log 'break: ' +break_
				console.log 'ip: '+ req.ip
				console.log 'this is the header host: ' + req.headers.host
				###
Here is the code that selects the user 'anonymous'. This user has different id depending on the server.
If the user has logged in through our mediaInterface then it will not use the anonymous user but the selected user.
				###
				if(req.headers.host is 'localhost:3000')
					#Change this to your own LOCAL user
					#onepagerUser = '5097ae8bae4d4a8805000001'
					onepagerUser = '509b933292083a3c07000002'
					console.log 'in IF'
				if(req.headers.host is 'www.breakitapp.com' or req.headers.host is 'breakitapp.com')
					# PROD SERVER ANON USER
					onepagerUser = '5110eff913e66edb527cb501'
				if(req.headers.host is 'www.breakit.info' or req.headers.host is 'breakit.info')
					# DEV SERVER ANON USER
					onepagerUser = '50a369413268496061000002'
					console.log 'ADMINCODE IS: ' + req.params.admincode
				if(req.params.admincode is 'd0lph1n')
					console.log 'ADMIN LOGIN IN site.coffee'
					console.log 'onepagerUser: ' + req.params.user
					onepagerUser = req.params.user
				console.log 'user: '+ onepagerUser
				console.log 'user is: '+ onepagerUser
				console.log 'REQUEST HOST: '+req.headers.host

				#for(head in req.headers)
					#console.log 'head'+head
				console.log 'HELLO !!!!'
				console.log 'admincode: '+ req.params.admincode
				if(req.params.admincode is 'd0lph1n')
					res.render 'onepage', title : 'Breakit - ' + break_.headline, b: break_, u: onepagerUser, mediaInterface:fromMedia, admincode:'d0lph1n'
				else
					res.render 'onepage', title : 'Breakit - ' + break_.headline, b: break_, u: onepagerUser, mediaInterface:fromMedia
	else
		breaks.addView req.params.id, (err, break_) ->
			if err
				res.send '404'
			else
				#console.log 'break: ' +break_
				console.log 'this is the header host: ' + req.headers.host
				if(req.headers.host is 'localhost:3000')
					#Change this to your own LOCAL user
					#onepagerUser = '5097ae8bae4d4a8805000001'
					onepagerUser = '509b933292083a3c07000002'
					console.log 'in IF'
				if(req.headers.host is 'www.breakitapp.com' or req.headers.host is 'breakitapp.com')
					# PROD SERVER ANON USER
					onepagerUser = '5110eff913e66edb527cb501'
				if(req.headers.host is 'www.breakit.info' or req.headers.host is 'breakit.info')
					# DEV SERVER ANON USER
					onepagerUser = '50a369413268496061000002'
				if(String(req.params.admincode) is 'd0lph1n')
					console.log 'ADMIN LOGIN IN site.coffee'
					console.log 'onepagerUser: ' + req.params.user
					onepagerUser = req.params.user
				console.log 'user before rendering: '+ onepagerUser
				console.log 'HELLO2 !!! '
				console.log 'HELLO2 !!! '
				console.log '(String(req.params.admincode) :'+ (String(req.params.admincode))
				if(String(req.params.admincode) is 'd0lph1n')
					res.render 'onepage', title : 'Breakit - ' + break_.headline, b: break_, u: onepagerUser, mediaInterface:fromMedia, admincode:'d0lph1n'
				else
					console.log 'onepageUser: '+onepagerUser
					console.log 'media: '+fromMedia
					console.log 'break: '+break_
					console.log 'break: '+break_.headline
					res.render 'onepage', title : 'Breakit - ' + break_.headline, b: break_, u: onepagerUser, mediaInterface:fromMedia

exports.webComment = (req, res) ->
	console.log 'in webComment'
	console.log 'req.body.admincode '+req.body.admincode
	console.log 'req.body.userId '+ req.body.userId
	console.log 'req.body.mediaInterface '+req.body.mediaInterface
	if req.body.admincode is 'd0lph1n'
		console.log 'admin commenting'
	else
		console.log 'no admin'
	#Check for query objects
	queryObject = require('url').parse(req.url,true).query
	checkMediaInterface = req.body.mediaInterface
	users.findById req.body.userId, (err, author) ->
		if err
			console.log 'error in finding user'
			throw err
		else
			console.log 'author: ' + author
			newComment = new comments.Comment req.body.comment, author._id, author.nName
			console.log 'New comment from web interface: ' + newComment.comment + ', author(anonymous): ' + author.nName
			breaks.comment newComment, req.body.breakId, (err, commentCount) ->
				if err
					res.send 'Commenting failed.'
				else
					#if the media boolean is set to true (page has oriented from media interface)
					if checkMediaInterface is 'media'
						if typeof queryObject.page isnt 'undefined'
						#Set the page number to same as from which page it has arrived from media interface
							pageNumber = '&page' + queryObject.page
					if req.body.admincode is 'd0lph1n'
						res.redirect '/p/' + req.body.breakId + '/' + req.body.userId + '/d0lph1n/' + checkMediaInterface + '/' + pageNumber
					else
						#media is empty and pagenumber is undefined
						res.redirect '/p/' + req.body.breakId + '/' + req.body.userId + '/' + 'true' + '/' + '1'


### I DON*T KNOW WHY WE ARE KEEPING THIS ANYMORE HEre -Marko
exports.pvs2 = (req, res) ->
	cookieName = ''
	cookieValue = ''
	cookies = {}
	req.headers.cookie && req.headers.cookie.split(';').forEach (cookie) ->
		parts = cookie.split '='
		checkCookie = cookies[parts[0].trim()] = (parts[0] || '').trim()
		console.log checkCookie
		if checkCookie is 'breakit'
			cookieName = cookies[parts[0].trim()] = (parts[0] || '').trim()
			cookieValue = cookies[parts[0].trim()] = (parts[1] || '').trim()
			console.log 'cookie ' + cookieName + ' with value ' + cookieValue + ' is now set!'
	console.log 'name: ' + cookieName
	console.log 'value: ' + cookieValue
	console.log 'id: ' + req.params.id 
	if cookieName is 'breakit' and cookieValue is req.params.id
		breaks.findById req.params.id, (err, break_) ->
			if err
				res.send '404'
			else
				#console.log 'break: ' +break_
				console.log 'ip: '+ req.ip
				if(req.headers.host is 'localhost:3000')
					#Change this to your own LOCAL user
					#onepagerUser = '5097ae8bae4d4a8805000001'
					onepagerUser = '50c9f32b6684c6ac05000001'
					console.log 'in IF'
				if(req.headers.host is '54.247.69.189')
					# PROD SERVER ANON USER
					onepagerUser = '51092bab602f21cea5c4b0ae'
				if(req.headers.host is '46.137.122.206')
					# DEV SERVER ANON USER
					onepagerUser = '50a369413268496061000002'
				console.log 'user: '+ onepagerUser
				console.log 'user is: '+ onepagerUser
				console.log 'REQUEST HOST: '+req.headers.host

				#for(head in req.headers)
					#console.log 'head'+head
				res.render 'onepage_vs2', title : 'Breakit - ' + break_.headline, b: break_, u: onepagerUser
	else
		breaks.addView req.params.id, (err, break_) ->
			if err
				res.send '404'
			else
				#console.log 'break: ' +break_
				if(req.headers.host is 'localhost:3000')
					#Change this to your own LOCAL user
					#onepagerUser = '5097ae8bae4d4a8805000001'
					onepagerUser = '50c9f32b6684c6ac05000001'
					console.log 'in IF'
				if(req.headers.host is '54.247.69.189')
					# PROD SERVER ANON USER
					onepagerUser = '51092bab602f21cea5c4b0ae'
				if(req.headers.host is '46.137.122.206')
					# DEV SERVER ANON USER
					onepagerUser = '50a369413268496061000002'
				console.log 'user: '+ onepagerUser
				res.render 'onepage_vs2', title : 'Breakit - ' + break_.headline, b: break_, u: onepagerUser
			
###

#Commenting for Onepager vs2
exports.onePComment = (req, res) ->
	users.findById req.body.userId, (err, author) ->
		if err
			throw err
		else
			newComment = new comments.Comment req.body.comment, author._id, author.nName

			console.log 'New comment from web interface: ' + newComment.comment + ', author(anonymous): ' + author.nName
			breaks.comment newComment, req.body.breakId, (err, commentCount) ->
				if err
					res.send 'Commenting failed.'
				else
					res.redirect '/p/' + req.body.breakId
			
exports.signup = (req, res) ->
	res.render 'signup_new' #change to signup_new when new template has been tested
	
exports.signup_post = (req, res) ->
	user = new models.BetaUser
		email		:		req.body.email
		phone		:		req.body.phone

	user.save (err) ->
		if err 
			res.send 'Your email address has been already registered.'
		else
			console.log 'new beta user: '
			console.log 'email : ' + req.body.email
			console.log(user)

			transport = mailer.createTransport 'SES', {
				AWSAccessKeyID : 'AKIAJD3WZOFBSHHZCIYQ'
				AWSSecretKey : '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'
			}

			mailOptions = 
				from : 'Breakit Info <info@breakitapp.com>'
				to: req.body.email
				subject:  'Thank you for registering for Breakit beta'
				generateTextFromHTML: true
				#TODO this needs to be in some separate file. this is just stupid.
				html: '<h1>Welcome to test the Breakit beta</h1> <p>We’re thrilled to have you on board!<br>  We’ll notify you as soon as Breakit is ready for testing. All the feedback that you could possibly come up with at this stage, and later, will be much appreciated. We are not building this service for us personally, it´s being built for you guys out there so do pitch in your ideas for development!<br><br> In the meantime keep updated by checking out our FB page <a href="http://www.facebook.com/breakitstories">Breakit</a> and follow us on Twitter #Breakitapp<br><br> Soon you’ll be able to both share and see things that are happening around you.<br><br> Cheers, <br><br>Breakit team Jolle, Mikko, Marko, Eerik, Binit, and Seb'

	
			transport.sendMail mailOptions, (err, response) ->
				if err
					console.log err
				else
					console.log "Message sent: " + response.message
			
				res.render('signup_new_confirm')

#This is not the right place for this route.
#TODO Move this somewhere else
exports.send = (req, res) ->
	console.log 'in send'
	models.BetaUser.find().exec (err, data) ->
		if err
			console.log 'USER: Failed to find any users.'
			callback null
		else
			betausers = (user for user in data)
			console.log 'betausers' +betausers
		if betausers == null
			res.send('No users found.')
		else
			content = '<h1> Betatester list </h1>:<br/><br/>' 
			i = 0
			for user in betausers
				i++
				content += '<br /><h2>Betatester ' + i + '</h2><br /> <p>email: ' + user.email + '<br /> phone: ' + user.phone + '<br /> date: ' + user.date+'</p>'
#TODO: PARSE CONTENT TO A MORE USABLE FORM
#TODO: CHANGE EMAIL TO eg. SKRUDES
#TODO: IMPLEMENT SECURITY AGAINST FLOODING

			transport = mailer.createTransport 'SES', {
				AWSAccessKeyID : 'AKIAIKWD2FS7UIATHYSQ'
				AWSSecretKey : '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'
			}

			mailOptions = 
				from : 'Breakit Info <info@breakitapp.com>'
				to: 'Marko Oksanen <marko@breakitapp.com>'
				subject:  'Beta tester list'
				generateTextFromHTML: true
				html: content
			transport.sendMail mailOptions, (err, response) ->
				if err
					console.log err
					res.send('ERROR')
				else
					console.log "Message sent: " + response.message
					console.log 'mail sent'
					res.send('SUCCESS')

exports.terms = (req, res) ->
	res.render 'blocks/terms', {title : 'Breakit terms and conditions'}

exports.terms_and_conditions = (req, res) ->
	res.render 'blocks/terms_and_conditions', {title : 'Breakit terms and conditions'}
