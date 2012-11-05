exports.index = (req, res) ->
	res.send 'This route is used for testing stuff'
	

exports.sendForm= (req, res) ->
		res.render 'test_templates/testform', title : 'Test sending a form to server'

exports.submitForm= (req, res) ->
		test = req.body.key1
		console.log req.body
		res.send 'Key1: '+test
