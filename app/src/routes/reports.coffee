reports = require '../models/reportModel'
breaks = require '../models/breakModel'

exports.login = (req, res) ->

	res.render 'adminlogin_reports', title: 'Breakit admin login'

exports.view = (req, res) ->
	
	if String(req.body.admincode) is "d0lph1n" #hardcoded password atm. TODO: make the admin authentication properly
	
		reports.list (err, reports) ->
			res.render 'blocks/reportList', title : 'Breakit reported breaks:', reports: reports
	else
		res.redirect('/reports/')
	
exports.delete = (req, res) ->
	breaks.del req.body.breakId, (err) ->
		if err
			res.send('Deleting failed.')
		else
			reports.deleteReportsByBreak req.body.breakId, (err) ->
				if err
					res.send('Break deleted but the reports still remain (error).')
				else
					res.send('Break deleted succefully.')
					
exports.clear = (req, res) ->
	reports.deleteReportsByBreak req.body.breakId, (err) ->
		if err
			res.send('Error removing reports.')
		else
			res.send('Reports related to the break removed successfully.')

