(($) ->
	breaks = [
		{name: 'lololol', points: '1000'}
		{name: 'trololo', points: '10'}
	]

	window.Break = Backbone.Model.extend
		defaults:
			beta: false

	window.BreakList = Backbone.Collection.extend
		model: Break

	BreakView = Backbone.View.extend
		tagName		:	'div'
		className	:	'break'
		template	:	$('#breakTemplate').html()

		initialize: ->
			_.bindAll this, 'render', 'remove'
			@model.bind 'change', @render
			@model.bind 'destroy', @remove

		render: ->
			tmpl = _.template @template
			@.$el.html tmpl @model.toJSON()
			return @

		remove: ->
			$(@el).remove()


	window.AppView = Backbone.View.extend
		el: $('#breakFeed')

		initialize: ->
			@collection = new BreakList(breaks)
			@render()

		render: ->
			that = @
			_.each @collection.models, (item) ->
				that.renderBreak item
			, @

		renderBreak: (item) ->
			breakView = new BreakView
				model: item
			@.$el.append breakView.render().el 

	appView = new AppView
	)(jQuery)
