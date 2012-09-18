###
# Breakit Web app
# Routes for the site
# Author: Mikko Majuri
###
exports.index = (req, res) ->
	res.render 'index', title: 'Breakit web-app, build with node, coffeescript and backbone'

exports.break_tmp = (req, res) ->
	res.render 'tmp/break', title: 'Break-template'

exports.ios = (req, res) ->
	console.log req.body.lat
	console.log req.body.lon
	res.render 'index', title: 'IOS-client'
