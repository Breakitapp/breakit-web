###
# Breakit web server. Written in Coffeescript
# v 1.0.0
# Mikko Majuri (majuri.mikko@gmail.com)
###

express				= require 'express'
site					= require './app/lib/routes/site'
user					= require './app/lib/routes/user'
breaks				= require './app/lib/routes/breaks'
settings			= require './settings'
mongoose			= require 'mongoose'
stylus				= require 'stylus'

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


#Users
server.all '/users', user.list
server.get '/users/new', user.create
server.post '/users/new', user.submit
server.get '/users/:id', user.view
server.post '/users/:id', user.update
#server.post '/users/:id', user.submit
server.delete '/users/:id', user.remove #todo

#Breaks (had to use breaks instead of break, since break is a reserved word)
server.get '/breaks', breaks.list
server.get '/breaks/:id', breaks.view
server.post '/breaks/:id', breaks.create

#Starting the server
server.listen 3000
console.log 'Breakit express server listening to port 3000 in dev mode'
#console.log 'Express server listening on port %d in %s mode', server.address().port, server.settings.env
