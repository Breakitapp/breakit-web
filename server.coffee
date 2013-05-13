###
# Breakit web server. Written in Coffeescript
###

express			= require 'express'
site				= require './app/lib/routes/site'
user				= require './app/lib/routes/user'
breaks			= require './app/lib/routes/breaks'
albums			= require './app/lib/routes/albums'
feedback		= require './app/lib/routes/feedback'
ios					= require './app/lib/routes/ios'
reports			= require './app/lib/routes/reports'
#blog				= require './app/lib/routes/blog'
media				= require './app/lib/routes/mediaInterface'
scripts			=	require	'./scripts/migration'
settings		= require './settings'
mongoose		= require 'mongoose'
stylus			= require 'stylus'
nconf				= require 'nconf'
server = module.exports = express()

#poet = require('poet') server

#Configuration
server.configure ->
	publicDir	= __dirname + '/web'
	viewsDir	= __dirname + '/web/templates'

	#Set the views folder
	server.set 'views', viewsDir
	#Set the view engine and options
	server.set 'view engine', 'jade'
	server.set 'view options', layout: false
	#Use middleware
	server.use express.bodyParser()
	server.use express.methodOverride()
	#CSS templating
	server.use(stylus.middleware src: publicDir)
	server.use express.static publicDir
	server.use server.router
#blogstuff:	server.use poet.middleware()

server.configure "development", ->
	server.use express.errorHandler(
		dumpExceptions: true
		showStack: true
	)
	db = mongoose.connect(settings.mongo_dev.db)
	nconf.env().argv()
	nconf.set 'NODE_ENV', 'development'
	console.log 'SETTING THE CONFIGURATION NODE_ENV TO DEV'
	console.log 'RUNNING ON DEV SERVER'

server.configure "production", ->
	server.use express.errorHandler()
	db = mongoose.connect(settings.mongo_prod.db)
	nconf.env().argv()
	nconf.set 'NODE_ENV', 'production'
	console.log 'SETTING THE CONFIGURATION NODE_ENV TO PRODUCTION'
	console.log 'RUNNING ON PRODUCTION SERVER'

server.configure "local", ->
	server.use express.errorHandler(
		dumpExceptions: true
		showStack: true
	)
	db = mongoose.connect(settings.mongo_local.db)
	nconf.env().argv()
	nconf.set 'NODE_ENV', 'local'
	console.log 'SETTING THE CONFIGURATION NODE_ENV TO LOCAL'
	console.log 'RUNNING ON LOCAL SERVER'


### Another way to do the conf 
if String(server.get 'env') is String('local')
	nconf.env().argv()
	nconf.set 'NODE_ENV', 'local'
	console.log 'SETTING THE CONFIGURATION NODE_ENV TO LOCAL'
else if String(server.get 'env') is String('development')
	nconf.env().argv()
	nconf.set 'NODE_ENV', 'development'
	console.log 'SETTING THE CONFIGURATION NODE_ENV TO DEV'
else
	nconf.env().argv()
	nconf.set 'NODE_ENV', 'production'
	console.log 'SETTING THE CONFIGURATION NODE_ENV TO PRODUCTION'
###

#General
server.all '/', site.signup

#Check if server is started as dev or local.
if String(server.get 'env') is String('local') or String(server.get 'env') is String('development')
	server.configure ->
		#Users
		server.get '/users/new', user.create
		server.post '/users/new', user.submit
		server.all '/users', user.list
		server.get '/users/:id', user.view
		server.post '/users/:id', user.update
		server.post '/users/delete/:id', user.remove
		#Breaks 
		server.all '/breaks', breaks.list
		server.get '/breaks/new', breaks.webCreate
		server.post '/breaks/new', breaks.webSubmit
		server.get '/breaks/comment', breaks.comment
		server.post '/breaks/comment', breaks.postComment
		server.post '/breaks/vote', breaks.vote
		server.post '/breaks/delete', breaks.delete
		#Albums
		server.all '/albums', albums.list
		#Creating a feedback for test
		server.get '/feedback/new', feedback.create
		server.post '/feedback/new', feedback.submit
		
#Terms & Conditions
server.get '/terms', site.terms
server.get '/terms_and_conditions', site.terms_and_conditions

#server.get '/blog', blog.index


#Feedback
server.get '/feedback', feedback.login
server.post '/feedback', feedback.view
server.post '/feedback/reply', feedback.reply
server.post '/feedback/remove', feedback.remove
#iOS
server.post '/ios', ios.index
server.post '/ios/login', ios.login
server.post '/ios/new_user', ios.newUser
server.post '/ios/new_break', ios.postBreak
server.post '/ios/delete_break', ios.deleteBreak
server.post '/ios/report_break', ios.reportBreak
server.post '/ios/comment', ios.postComment
server.post '/ios/vote', ios.vote
server.post '/ios/feedback', ios.feedbackCreate
server.post '/ios/tweet', ios.tweet
server.post '/ios/fb', ios.fbShare
server.post '/ios/change_nick', ios.changeUserAttributes
server.post '/ios/sendPushNotification', ios.sendPushNotification

server.get '/ios/picture/:id', ios.getPicture
server.get '/ios/thumb/:filename', ios.getThumb
server.get '/ios/info/:id', ios.getBreak
server.get '/ios/browse_album/:albumId/:page', ios.browseAlbum
server.get '/ios/whole_album/:albumId/:page', ios.getAlbumBreaks
server.get '/ios/mybreaks/:userId/:page', ios.getMyBreaks
server.get '/ios/mynotifications/:userId', ios.getMyNotifications

#Reports
server.get '/reports', reports.login
server.post '/reports', reports.view
server.post '/reports/delete', reports.delete
server.post '/reports/clear', reports.clear

#WEB
#Public break interface
server.get '/p/:id', site.public
server.get '/p/:id/:user/:admincode/:media/:page', site.public
server.get '/p/:id/:user/:media/:page', site.public
server.get '/p/:id/:media/:page', site.public
server.post '/p/comment', site.webComment
#Onepager vs2 under editing
#server.get '/p/:id', site.pvs2 # <- naming?? -e
#server.post '/p/comment', site.onePComment
#add here also other things that the web interface needs to use...

#Signup
server.get '/signup', site.signup
server.post '/signup', site.signup_post
#Emails the betatesters list (currently to Marko)
server.get '/signup/send', site.send

#MEDIA INTERFACE
#TODO: Check
server.all '/media', media.mediaInterface
server.get '/media/login', media.login
server.get '/media/:pageNumber', media.mediaInterface
server.get '/media/:user/:admincode/:pageNumber', media.loginAsAdmin

server.post '/media/login', media.view
server.post '/media/loginAs', media.loginAsAdmin
server.post '/media/newUser', media.view

server.post '/webNotifications', site.webNotifications
server.post '/sendNotification', site.webSendNotification
server.post '/sendNotificationToAll', site.webSendNotificationToAll

server.get '/webNotifications/login', site.webNotificationsLogin

server.get '/welcome', ios.getWelcomeScreenPics




###
server.get( '/blog/post/:post', blog.post
server.get( '/blog/tag/:tag', blog.post
server.get( '/blog/category/:category', blog.post
server.get( '/blog/page/:page', blog.post
###

###
app.get( '/tag/:tag', function ( req, res ) {
  var taggedPosts = req.poet.postsWithTag( req.params.tag );
  if ( taggedPosts.length ) {
    res.render( 'tag', {
      posts : taggedPosts,
      tag : req.params.tag
    });
  }
});

app.get( '/category/:category', function ( req, res ) {
  var categorizedPosts = req.poet.postsWithCategory( req.params.category );
  if ( categorizedPosts.length ) {
    res.render( 'category', {
      posts : categorizedPosts,
      category : req.params.category
    });
  }
});

app.get( '/page/:page', function ( req, res ) {
  var page = req.params.page,
    lastPost = page * 3
  res.render( 'page', {
    posts : req.poet.getPosts( lastPost - 3, lastPost ),
    page : page
  });
});
###

#Starting the server
server.configure "local", ->
	server.listen 3000
	console.log 'Breakit express server listening to port 3000 in dev mode'

server.configure "development", ->
	server.listen 80
	console.log 'Breakit express server listening to port 80 in dev mode'

server.configure "production", ->
	server.listen 80
	console.log 'Breakit express server listening to port 80 in production mode'
