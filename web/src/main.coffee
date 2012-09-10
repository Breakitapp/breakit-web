require.config  ->
	paths:
		loader			: '../public/js/libs/loader'
		jQuery			: '../public/js/libs/jquery'
		Underscore	: '../public/js/libs/underscore'
		Backbone		: '../public/js/libs/backbone'
		Jade				:	'../public/js/libs/jade'
		templates		: '../templates'

require : ['app'] (app) ->
	App.initialize()
