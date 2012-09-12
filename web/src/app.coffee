(($) ->
	alert 'böö again muthafucka'
	breaks = [
		{name: 'lololol', points: '1000'}
		{name: 'trololo', points: '10'}
	]
	window.Break = Backbone.Model.extend
		defaults:
			photo: '/img/placeholder.png'


	window.BreakList = Backbone.Collection.extend
		model: Break

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

		remove: ->
			$(@el).remove()

	window.AppView = Backbone.View.extend
		el: $('#breakFeed')

		initialize: ->
			alert 'suplies, muthafucka!'
			console.log 'suplies, muthafucka!'
			@collection = new BreakList(breaks)
			@render()

		render: ->
			that = @
			_.each @collection.models, (item) ->
				that.renderBreak item
			, @

		renderBreak: (item) ->
			breakView = new breakView
				model: item
			@$el.append breakView.render().el 

	appView = new AppView
	)(jQuery)
