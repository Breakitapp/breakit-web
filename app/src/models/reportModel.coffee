models = require './mongoModel'

class Report
	constructor: (@breakId, @userId) ->
		console.log Date.now() + ': REPORT FOR INAPPROPRIATE BREAK '+ @breakId + ' by user ' + @userId

	saveToDB: (callback) ->
				
		report = new models.Report
			breakId				:		@breakId
			userId 				:		@userId
		
		report.save (err) ->
			if err
				throw err
			else
				callback null

createReport = (breakId, userId, callback) ->
	
	report = new Report breakId, userId
	report.saveToDB (err) ->
		callback err

list = (callback) ->
	models.Report.find().exec (err, reports) ->
		console.log reports.length
		callback err, reports
		
deleteReportsByBreak = (breakId, callback) ->
	models.Report.find({breakId : breakId}).exec (err, reports) ->
		if err
			callback err
		else
			for report in reports
				report.remove (err) ->
					callback err

deleteReport = (reportId, callback) ->
	models.Report.findbyId(reportId).exec (err, report) ->
		if err
			callback err
		else
			report.remove (err) ->
				callback err
		
root = exports ? window
root.list = list
root.deleteReport = deleteReport
root.deleteReportsByBreak = deleteReportsByBreak
root.Report = Report
root.createReport = createReport
