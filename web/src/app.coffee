(($) ->
	breaks = [
		{name: 'lololol', story: 'tämä on tarina, fuck yeah', user: 'herra hakkarainen', headline: 'onko tässä headeri'}
		{name: 'moikke', story: 'tässäkin tarina', user: 'herra hakkarainen', headline: 'on tässä headeri'}
	]

	window.Break = Backbone.Model.extend
		defaults:
			beta: false

	window.BreakList = Backbone.Collection.extend
		model: Break
		url: -> 
			return '/breaks/' + page
		page = 1

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
		el: '#breakFeed'

		initialize: ->
			@collection = new BreakList(breaks)
			@render()

		render: ->
			@loadResults()
			
		loadResults: ->
			that = @
			@collection.fetch
				success	: (breaks) ->
					_.each breaks.models, (item) ->
						that.renderBreak item
						, @

		events: 
			'scroll' : 'checkScroll'

		checkScroll: ->
			#alert 'böö muthafucka!'
			triggerPoint : 100
			#if @el.scrollTop + @el.clientHeight + triggerPoint > @el.scrollHeight
			alert 'load more breaks!'
			@collection.page += 1
			alert 'onward to page '+ @collection.page 
			@loadResults()

		renderBreak: (item) ->
			breakView = new BreakView
				model: item
			console.log @$el
			@.$el.append breakView.render().el 

	appView = new AppView
	)(jQuery)
