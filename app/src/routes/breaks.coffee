breaks = require '../models/breakModel'

exports.list = (req, res) ->
	breaks.findAll (err, data) ->
		#errorhandling goes here
		res.render 'test', title : 'testing', data : data

exports.create = (req, res) ->
	breaks.create
