define([
	'Underscore',
	'Backbone'
], (_, Backbone) ->
	breakModel = Backbone.Model.extend
		defaults :
			name : 'Anonymous break'
			location : 'In my pants'
			user : 'Hotty McHottie'

	return breakModel
)
