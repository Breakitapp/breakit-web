report = require '../models/reportModel'

exports.view = (req, res) ->
	report.list (err, reports) ->
		
		console.log reports
		
		res.render 'blocks/reportList', title : 'Breakit reported breaks:', reports: reports 