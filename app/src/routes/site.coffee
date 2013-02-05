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
					onepagerUser = '50a0a149aa090b8c11000001'
					console.log 'in IF'
				if(req.headers.host is '54.247.69.189')
					# PROD SERVER ANON USER
					onepagerUser = '5110eff913e66edb527cb501'
				if(req.headers.host is '46.137.122.206')
					# DEV SERVER ANON USER
					onepagerUser = '50a369413268496061000002'
				console.log 'user: '+ onepagerUser
				console.log 'user is: '+ onepagerUser
				console.log 'REQUEST HOST: '+req.headers.host

				#for(head in req.headers)
					#console.log 'head'+head
				res.render 'onepage', title : 'Breakit - ' + break_.headline, b: break_, u: onepagerUser
	else
		breaks.addView req.params.id, (err, break_) ->
			if err
				res.send '404'
			else
				#console.log 'break: ' +break_
				if(req.headers.host is 'localhost:3000')
					#Change this to your own LOCAL user
					#onepagerUser = '5097ae8bae4d4a8805000001'
					onepagerUser = '50a0a149aa090b8c11000001'
					console.log 'in IF'
				if(req.headers.host is '54.247.69.189')
					# PROD SERVER ANON USER
					onepagerUser = '50a0e4db1f63ba4d72000020'
				if(req.headers.host is '46.137.122.206')
					# DEV SERVER ANON USER
					onepagerUser = '50a369413268496061000002'
				console.log 'user: '+ onepagerUser
				res.render 'onepage', title : 'Breakit - ' + break_.headline, b: break_, u: onepagerUser
			

exports.webComment = (req, res) ->
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

#Onepager vs2
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
					
