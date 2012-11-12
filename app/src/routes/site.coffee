###
# Breakit Web app
# Routes for the site
# Author: Mikko Majuri
###

models = require '../models/mongoModel'
mailer = require 'nodemailer'
breaks = require '../models/breakModel'
users = require '../models/userModel'

exports.index = (req, res) ->
	res.render 'index', title: 'Breakit web-app, build with node, coffeescript and backbone'

exports.break_tmp = (req, res) ->
	res.render 'tmp/break', title: 'Break-template'
	
exports.public = (req, res) ->
	breaks.findById req.params.id, (err, break_) ->
		if err
			res.send '404'
		else
			#console.log 'break: ' +break_
			res.render 'public', title : 'Breakit - ' + break_.headline, b: break_

exports.onepage= (req, res) ->
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
			newComment = new comments.Comment req.body.comment, req.body.userId, author.nName

			console.log 'new comment from web interface: ' + newComment.comment
			breaks.comment newComment, req.body.breakId, (err, commentCount) ->
				if err
					res.send 'Commenting failed.'
				else
					breaks.findById req.body.breakId, (err, break_) ->
						if err
							res.send '404'
						else
							#console.log 'break: ' +break_
							res.redirect '/onep/' + req.body.breakId

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
			
				res.render('signup_confirm');

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
				AWSAccessKeyID : 'AKIAJD3WZOFBSHHZCIYQ'
				AWSSecretKey : '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'
			}

			mailOptions = 
				from : 'Breakit Info <admin@breakitapp.com>'
				to: 'marko.oksanen@aceconsulting.fi'
				subject:  'Beta tester list'
				generateTextFromHTML: true
				html: content
