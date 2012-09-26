###
# Breakit Web app
# Routes for the site
# Author: Mikko Majuri
###

models = require '../models/mongoModel'
mailer = require 'nodemailer'

exports.index = (req, res) ->
	res.render 'index', title: 'Breakit web-app, build with node, coffeescript and backbone'

exports.break_tmp = (req, res) ->
	res.render 'tmp/break', title: 'Break-template'
	
exports.signup = (req, res) ->
	res.render 'signup'
	
exports.signup_post = (req, res) ->
	email = req.body.email
	user = new models.User
		email		:		email
		beta		:		'true'
		phone		:		req.body.phone

	user.save (err) ->
		if err 
			throw err
		console.log 'new beta user: '
		console.log(user)

	transport = mailer.createTransport 'SES', {
		AWSAccessKeyID : 'AKIAJD3WZOFBSHHZCIYQ'
		AWSSecretKey : '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'
	}

	mailOptions = 
		from : 'Breakit Info <info@breakitapp.com>'
		to: email
		subject:  'Thank you for registering for Breakit beta'
		generateTextFromHTML: true
		html: '<h1>Welcome to test the Breakit beta</h1> <p>We’re thrilled to have you on board!<br>  We’ll notify you as soon as Breakit is ready for testing. All the feedback that you could possibly come up with at this stage, and later, will be much appreciated. We are not building this service for us personally, it´s being built for you guys out there so do pitch in your ideas for development!<br><br> In the meantime keep updated by checking out our FB page <a href="http://www.facebook.com/breakitstories">Breakit</a> and follow us on Twitter #Breakitapp!<br><br> Soon you’ll be able to both share and see things that are happening around you.<br><br> Cheers, <br><br>Breakit team Jolle, Mikko, Marko, Binit, and Seb'

	
	transport.sendMail mailOptions, (err, response) ->
		if err
			console.log err
		else
			console.log "Message sent: " + response.message
			
	res.render('signup_confirm');

