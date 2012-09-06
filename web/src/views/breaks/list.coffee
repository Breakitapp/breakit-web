define([
	'jQuery',
	'Underscore',
	'Backbone',
	'text!templates/break/list.html'
], ($, _, Backbone, breakListTemplate) ->
	breakListView = Backbone.View.extend ->
		el: $('#container')

		render: ->
			data = {}
			compiledTemplate = _.template(breakListTemplate, data)
			@el.append(compiledTemplate)
	return new breakListView
)
