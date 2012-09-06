define(['order!../public/js/libs/jquery-min', 'order!../public/js/libs/underscore-min', 'order!../public/js/libs/backbone-min'],
function(){
	return {
		Backbone: Backbone.noConflict(),
		_: _.noConflict(),
		$: jQuery.noConflict()
	};
});
