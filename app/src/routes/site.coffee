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


###
exports.index = (req, res) ->
	res.redirect '/signup'
###

exports.break_tmp = (req, res) ->
	res.render 'tmp/break', title: 'Break-template'

###
exports.public = (req, res) ->
	breaks.findById req.params.id, (err, break_) ->
		if err
			res.send '404'
		else
			#console.log 'break: ' +break_
			res.render 'public', title : 'Breakit - ' + break_.headline, b: break_
###

exports.public= (req, res) ->
	breaks.findById req.params.id, (err, break_) ->
		if err
			res.send '404'
		else
			#console.log 'break: ' +break_
			res.render 'onepage', title : 'Breakit - ' + break_.headline, b: break_

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

exports.signup = (req, res) ->
	res.render 'signup' #change to signup_new when new template has been tested
	
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
				html: '<h1>Welcome to test the Breakit beta</h1> <p>We’re thrilled to have you on board!<br>  We’ll notify you as soon as Breakit is ready for testing. All the feedback that you could possibly come up with at this stage, and later, will be much appreciated. We are not building this service for us personally, it´s being built for you guys out there so do pitch in your ideas for development!<br><br> In the meantime keep updated by checking out our FB page <a href="http://www.facebook.com/breakitstories">Breakit</a> and follow us on Twitter #Breakitapp!<br><br> Soon you’ll be able to both share and see things that are happening around you.<br><br> Cheers, <br><br>Breakit team Jolle, Mikko, Marko, Eerik, Binit, and Seb'

	
			transport.sendMail mailOptions, (err, response) ->
				if err
					console.log err
				else
					console.log "Message sent: " + response.message
			
				res.render('signup_confirm')

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
			content = '<h1> Marko testaa betalistaa' + betausers
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
			console.log 'mail sent'
			res.send('SUCCESS')