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
test				= require './app/lib/routes/test'
ios					= require './app/lib/routes/ios'
settings			= require './settings'
mongoose			= require 'mongoose'
stylus				= require 'stylus'
mediaint			=require './app/lib/routes/mediainterface'
#blog			= require './app/lib/routes/blog'
#Dummydata insert
#dummy					= require './app/lib/models/dummyModel'

server = module.exports = express()
#poet				= (require 'poet') server

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
	#POET blog
#	server.use(poet.middleware src: viewsDir)
	server.use express.static publicDir
	server.use server.router

###BLOG UNDER CONSTRUCTION 
poet.set
  posts: './_posts/',
  postsPerPage: 5,
  metaFormat: 'json'
poet
  .createPostRoute()
  .createPageRoute()
  .createTagRoute()
  .createCategoryRoute()
  .init()
###

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
	console.log 'RUNNING ON LOCAL SERVER'
	db = mongoose.connect(settings.mongo_local.db)
	
#General
server.all '/', site.signup
server.all '/break', site.break_tmp

server.configure "local", ->
	#TESTING FUNCTIONS
	server.get '/test', test.index

server.configure "development", ->
	#TESTING FUNCTIONS
	server.get '/test', test.index
	server.get '/test/sendForm', test.sendForm
	server.post '/test/sendForm', test.submitForm
	server.get '/test/userfeed', test.specifyFeed
	server.post '/test/userfeed', test.feed
	server.get '/breaks/new', breaks.webCreate
	server.post '/breaks/new', breaks.webSubmit
	server.get '/breaks/enew', breaks.easyWebCreate
	server.post '/breaks/enew', breaks.easyWebSubmit
	#USERS
	server.get '/users/new', user.create
	server.post '/users/new', user.submit
	#Users
	server.all '/users', user.list
	server.get '/users/:id', user.view
	server.post '/users/:id', user.update
	server.post '/users/delete/:id', user.remove
	#Breaks (had to use breaks instead of break, since break is a reserved word)
	server.all '/breaks', breaks.list
	server.get '/breaks/comment', breaks.comment
	server.post '/breaks/comment', breaks.postComment
	server.post '/breaks/vote', breaks.vote
	server.post '/breaks/delete', breaks.delete
	#MEDIA INTERFACE
	server.all '/media', breaks.mediaInterface
	#server.post '/media/search', breaks.searchMedia
	#Albums
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
server.post '/ios/new_user', ios.new_user
server.post '/ios/new_break', ios.post_break
server.post '/ios/delete_break', ios.delete_break
server.post '/ios/report_break', ios.report_break
server.post '/ios/comment', ios.post_comment
server.post '/ios/vote', ios.vote
server.post '/ios/feedback', ios.feedbackCreate
server.post '/ios/tweet', ios.tweet
server.post '/ios/fb', ios.fbShare
server.post '/ios/change_nick', ios.changeUserAttributes
server.get '/ios/picture/:id', ios.get_picture
server.get '/ios/info/:id', ios.get_break
server.get '/ios/browse_album/:albumId/:page', ios.browse_album
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

#Users
server.all '/users', user.list
server.get '/users/:id', user.view
server.post '/users/:id', user.update
server.post '/users/delete/:id', user.remove

#Breaks (had to use breaks instead of break, since break is a reserved word)
server.all '/breaks', breaks.list
server.get '/breaks/comment', breaks.comment
server.post '/breaks/comment', breaks.postComment
#server.post '/breaks/1pcomment', breaks.postComment_1page
server.post '/breaks/vote', breaks.vote
server.post '/breaks/delete', breaks.delete
#server.get '/breaks/:page', breaks.infinite #old

#MEDIA INTERFACE
server.all '/media', mediaint.mediaInterface
#server.post '/media/search', breaks.searchMedia

#Albums
server.all '/albums', albums.list
server.get '/albums/near/:page', albums.listNear
server.get '/albums/near', albums.listNear
server.get '/albums/new', albums.create
server.post '/albums/new', albums.submit

# BLOG
#server.get '/blog', blog.index

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
