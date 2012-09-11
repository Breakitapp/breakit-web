jade = require 'jade'
_ = require 'underscore'

jQuery ($) ->
	breaks = [
		name: 'lololol', points: '1000'
		name: 'trololo', points: '10'
	]
	window.Break = Backbone.Model.extend
		defaults:
			photo: '/img/placeholder.png'

	window.BreakList = Backbone.Collection.extend
		model: Break

	window.Breaks = new BreakList

	BreakView = Backbone.View.extend
		tagName		:	'div'
		className	:	'break'
		template	:	$('#breakTemplate').html()

		initialize: ->
			_.bindAll @, 'render', 'close', 'remove'
			@model.bind 'change', @render
			@model.bind 'destroy', @remove

		render: ->
			element = jQuery.tmpl @template, @model.toJSON()
			$(@el).html(element)
			return @

		remove: ->
			$(@el).remove()

	window.AppView = Backbone.View.extend
		el: $('#breakFeed')

		initialize: ->
			_.bindAll(@, 'render')

