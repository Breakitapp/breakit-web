###
# Breakit Web app
# Routes for the site
# Author: Mikko Majuri
###
exports.index = (req, res) ->
	res.render 'index', title: 'Breakit web-app, build with node, coffeescript and backbone'
