models = require './mongoModel'

class Report
	constructor: (@breakId, @userId) ->
		console.log Date.now() + ': REPORT FOR INAPPROPRIATE BREAK  '+ @breakId + ' by user ' + @userId

	saveToDB: (callback) ->
				
		report = new models.Report
			breakiId			:		@breakId
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
		callback err, reports

deleteReport = (reportId, callback) ->

	models.Report.findbyId(reportId).exec (err, report) ->
		if err
			callback err, null
		else
			report.remove (err) ->
				callback err, null
		
root = exports ? window
root.list = list
root.deleteReport = deleteReport
root.Report = Report
root.createReport = createReport
