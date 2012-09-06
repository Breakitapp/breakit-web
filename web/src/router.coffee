define([
	'jQuery',
	'Underscore',
	'Backbone'
], ($, _, Backbone, Session, projectListView, userListView) ->
	AppRouter = Backbone.Router.extend ->
		routes :
			'/breaks'	: 'showBreaks'
			'/users'	: 'showUsers'

			'*actions': 'defaultAction'

		showBreaks : ->
			breakListView.render()

		showUsers : ->
			userListView.render()

		defaultAction : (actions) ->
			console.log 'No route: ' + actions
	
	initialize : ->
		app_router = new AppRouter
		Backbone.history.start()
	return {
		initialize : initialize
	}
)
