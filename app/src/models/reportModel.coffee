models = require './mongoModel'

class Report
	constructor: (@breakId, @userId) ->
		console.log Date.now() + ': REPORT FOR INAPPROPRIATE BREAK  '+ @breakId + ' by user ' + @userId

	saveToDB: (callback) ->
				
		report = new models.Report
			breakiId				:		@breakId
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
		
root = exports ? window
root.Report = Report
root.createReport = createReport