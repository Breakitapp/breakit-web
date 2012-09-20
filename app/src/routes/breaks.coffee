breaks = require '../models/breakModel'

exports.list = (req, res) ->
	breaks.findNear 100, 65, 65, (err, docs) ->
		res.send docs
		
exports.create = (req, res) ->
	breaks.create
