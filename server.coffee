###
# Breakit web app. Written in Coffeescript
# v 1.0.0
# Mikko Majuri (majuri.mikko@gmail.com)
###

express				= require 'express'
site					= require './app/lib/routes/site'
user					= require './app/lib/routes/user'
breaks				= require './app/lib/routes/breaks'
#mongoStore		= require 'connect-mongo'.(express)
settings			= require './settings'
mongoose			= require 'mongoose'
stylus				= require 'stylus'

app = module.exports = express()

#Configuration
app.configure ->
	publicDir = __dirname + '/web/public'
	viewsDir  = __dirname + '/web/templates'
	coffeeDir = '#{viewsDir}/coffeescript'
	#Set the views folder
	app.set 'views', viewsDir
	#Set the view engine and options
	app.set 'view engine', 'jade'
	app.set 'view options', {layout: false}
	#Use middleware
	app.use express.bodyParser()
	app.use express.methodOverride()
	#CSS templating
	app.use(stylus.middleware debug: true, src: viewsDir, dest: publicDir, compile: compileMethod)
	app.use express.static(publicDir)
	###app.use app.cookieParser()
	#Initiate session handling through mongo
	app.use express.session({
		secret		:	settings.cookie_secret
		store			:	new mongoStore({
			db			:	settings.db
		})
	})
	app.use express.compiler(
		src: viewsDir, 
		dest: publicDir, 
		enable: ['coffeescript'])###
	app.use app.router

db = mongoose.connect(settings.mongo_auth.db)

compileMethod = (str, path) ->
	stylus(str)
		.set('filename', path)
		.set('compress', true)


app.configure "development", ->
	app.use express.errorHandler(
		dumpExceptions: true
		showStack: true
	)

app.configure "production", ->
	app.use express.errorHandler()


#General
app.get '/', site.index

#Users
app.all '/users', user.list
app.get '/users/:id', user.view
app.get '/users/:id/edit', user.edit
app.put '/users/:id/edit', user.update
app.post '/users/:id', user.create

#Breaks (had to use breaks instead of break, since break is a reserved word)
app.all '/breaks', breaks.list
app.get '/breaks/:id', breaks.view
app.post '/breaks/:id', breaks.create

#Starting the app
app.listen 3000
console.log 'Breakit express server listening to port 3000 in dev mode'
#console.log 'Express app listening on port %d in %s mode', app.address().port, app.settings.env
