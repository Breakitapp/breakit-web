report = require '../models/reportModel'

exports.view = (req, res) ->
	report.list (err, reports) ->
		res.render 'blocks/reportList', title : 'Breakit reported breaks:', reports: reports 