###
# Breakit web server. Written in Coffeescript
# v 1.0.0
# Mikko Majuri (majuri.mikko@gmail.com)
###

express				= require 'express'
site				= require './app/lib/routes/site'
user				= require './app/lib/routes/user'
breaks				= require './app/lib/routes/breaks'
albums				= require './app/lib/routes/albums'
feedback			= require './app/lib/routes/feedback'
ios					= require './app/lib/routes/ios'
settings			= require './settings'
mongoose			= require 'mongoose'
stylus				= require 'stylus'
#Dummydata insert
#dummy					= require './app/lib/models/dummyModel'

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

db = mongoose.connect(settings.mongo_auth.db)

server.configure "development", ->
	server.use express.errorHandler(
		dumpExceptions: true
		showStack: true
	)

server.configure "production", ->
	server.use express.errorHandler()


#General
server.all '/', site.index
server.all '/break', site.break_tmp

#iOS
server.post '/ios', ios.index
server.get '/ios/new_user', ios.new_user
server.post '/ios/comment', ios.post_comment
server.post '/ios/vote', ios.vote
server.post '/ios/feedback', ios.feedbackCreate
server.post '/ios/tweet', ios.tweet
server.post '/ios/fb', ios.fbShare
server.get '/ios/picture/:id', ios.get_picture
server.get '/ios/info/:id', ios.get_break
server.post '/ios/:user/:break', ios.post_break #change to /ios/newbreak
server.get '/ios/browse_album/:album/:page', ios.browse_album

#WEB
 
#Public break interface
server.get '/p/:id', site.public

#Signup
server.get '/signup', site.signup
server.post '/signup', site.signup_post
server.get '/signup/send', site.send

#Users
server.all '/users', user.list
server.get '/users/new', user.create
server.post '/users/new', user.submit
server.get '/users/:id', user.view
server.post '/users/:id', user.update
server.post '/users/delete/:id', user.remove

#Breaks (had to use breaks instead of break, since break is a reserved word)
server.all '/breaks', breaks.list
server.get '/breaks/new', breaks.webCreate
server.post '/breaks/new', breaks.webSubmit
server.get '/breaks/enew', breaks.easyWebCreate
server.post '/breaks/enew', breaks.easyWebSubmit
server.get '/breaks/comment', breaks.comment
server.post '/breaks/comment', breaks.postComment
server.post '/breaks/1pcomment', breaks.postComment_1page
server.post '/breaks/vote', breaks.vote
server.get '/breaks/:page', breaks.infinite

#Albums
server.all '/albums', albums.list
server.get '/albums/near/:page', albums.listNear
server.get '/albums/near', albums.listNear
server.get '/albums/new', albums.create
server.post '/albums/new', albums.submit
server.get '/albums/:album/:page', albums.feed

###
#Testing
server.get '/cookietest', breaks.cookieGet
server.post '/cookietest', breaks.cookiePost
###

#Creating a feedback for test
server.get '/feedback/new', feedback.create
server.post '/feedback/new', feedback.submit
server.get '/feedback/list', feedback.list

#Starting the server
server.listen 3000
console.log 'Breakit express server listening to port 3000 in dev mode'
#console.log 'Express server listening on port %d in %s mode', server.address().port, server.settings.env
