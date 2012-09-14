breaks = require '../models/breakModel'

exports.list = (req, res) ->
	breaks.findAll (err, data) ->
		#errorhandling goes here
		res.send data

exports.create = (req, res) ->
	breaks.create
