###
# Breakit migration scripts Written in Coffeescript
# v 1.0.0
# Mikko Majuri (majuri.mikko@gmail.com)
###

users		= require '../app/lib/models/userModel'
breaks	= require '../app/lib/models/breakModel'
fs			= require 'fs'

makeFileStructure =  (target_path) ->
	fs.mkdir target_path, '0777', (err) ->
		fs.mkdir target_path + '/images/', '0777', (err) ->
		console.log 'made new filestructure ' + target_path

movePicture = (path_now, target_path) ->
	console.log path_now, target_path
	fs.readFile path_now, (err, data) ->
		if err
			throw err
		fs.writeFile target_path, data, (err) ->
			if err
				console.log 'fail'
				throw err
			else
				console.log 'success'

exports.userDirectoryMigration = ->
	users.list (allUsers) ->
		for user in allUsers
			target_path = './app/res/user/' + user.id
			console.log target_path
			makeFileStructure target_path

exports.breakDirectoryMigration = ->
	breaks.findAll (err, allBreaks) ->
		for break_ in allBreaks
			path_now		= './app/res/images/' + break_._id + '.jpeg'
			target_path = './app/res/user/' + break_.user + '/images/' + break_._id + '.jpeg'
			movePicture path_now, target_path
