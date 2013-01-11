###
# Breakit web server. Written in Coffeescript
# v 1.0.0
# Mikko Majuri (majuri.mikko@gmail.com)
###

express			= require 'express'
site				= require './app/lib/routes/site'
user				= require './app/lib/routes/user'
breaks			= require './app/lib/routes/breaks'
albums			= require './app/lib/routes/albums'
feedback		= require './app/lib/routes/feedback'
test				= require './app/lib/routes/test'
ios					= require './app/lib/routes/ios'
mediaint		= require './app/lib/routes/mediainterface'
settings		= require './settings'
mongoose		= require 'mongoose'
stylus			= require 'stylus'

server = module.exports = express()

#Configuration
server.configure ->
	publicDir = __dirname + '/web'
	viewsDir  = __dirname + '/web/templates'

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

server.configure "development", ->
	server.use express.errorHandler(
		dumpExceptions: true
		showStack: true
	)
	console.log 'RUNNING ON DEV SERVER'
	db = mongoose.connect(settings.mongo_dev.db)

server.configure "production", ->
	server.use express.errorHandler()
	console.log 'RUNNING ON PRODUCTION SERVER'
	db = mongoose.connect(settings.mongo_prod.db)

server.configure "local", ->
	server.use express.errorHandler(
		dumpExceptions: true
		showStack: true
	)
	console.log 'RUNNING ON LOCAL SERVER'
	db = mongoose.connect(settings.mongo_local.db)

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
		#MEDIA INTERFACE
		server.all '/media', breaks.mediaInterface
		#Albums
		#Possibly outdated
		server.all '/albums', albums.list
		server.get '/albums/near/:page', albums.listNear
		server.get '/albums/near', albums.listNear
		server.get '/albums/new', albums.create
		server.post '/albums/new', albums.submit

#Creating a feedback for test
server.get '/feedback/new', feedback.create
server.post '/feedback/new', feedback.submit
server.get '/feedback/list', feedback.list

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
server.get '/ios/picture/:id', ios.getPicture
server.get '/ios/info/:id', ios.getBreak
server.get '/ios/browse_album/:albumId/:page', ios.browseAlbum
server.get '/ios/whole_album/:albumId/:page', ios.getAlbumBreaks
server.get '/ios/mybreaks/:userId/:page', ios.getMyBreaks
server.get '/ios/mynotifications/:userId', ios.getMyNotifications

#WEB
#Public break interface
server.get '/p/:id', site.public
server.post '/p/comment', site.webComment
#Onepager vs2 under editing
#server.get '/p/:id', site.pvs2 # <- naming?? -e
#server.post '/p/comment', site.onePComment
#add here also other things that the web interface needs to use...

#Signup
server.get '/signup', site.signup
server.post '/signup', site.signup_post
server.get '/signup/send', site.send

#MEDIA INTERFACE
server.all '/media', mediaint.mediaInterface
#server.post '/media/search', breaks.searchMedia

#Starting the server
server.configure "local", ->
	server.listen 3000
	console.log 'Breakit express server listening to port 3000 in dev mode'

server.configure "development", ->
	server.listen 80
	console.log 'Breakit express server listening to port 80 in dev mode'

server.configure "production", ->
	server.listen 80
	console.log 'Breakit express server listening to port 80 in dev mode'
