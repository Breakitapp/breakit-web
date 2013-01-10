breaks = require '../models/breakModel'
#This renders the index of mediainterface
exports.mediaInterface= (req, res) ->
	console.log '******************************************'
	console.log 'entering Media Interface'
	pageNumber = req.body.pageNumber
	currentSortPage = req.body.currentSortPage
	sortPage = req.body.sortPage
	if sortPage == undefined && currentSortPage == undefined
		sortPage = 'byDate'
	else if sortPage == undefined
		sortPage = currentSortPage
	console.log 'sortPage variable is: ' + sortPage
	if pageNumber == undefined
		pageNumber = 0
	else if pageNumber > 0
		pageNumber -= 1
	console.log 'testing searchValue: ' + req.body.searchValue
	console.log 'page number: ' + pageNumber
	if req.body.searchValue == undefined  && sortPage != 'search' || req.body.searchValue == 'search' && sortPage != 'search'
		console.log 'search function skipped'
		if sortPage == 'commented'
			console.log 'commented function in breaks.coffee'
			breaks.sortByComments pageNumber, sortPage, (err, breaks_, count, sortPageValue) ->
				console.log 'sort by comments'
				if err
					res.send 'No breaks found.'
				else
					res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue
		else if sortPage == 'viewed'
			console.log 'viewed function in breaks.coffee'
			breaks.sortByViews pageNumber, sortPage, (err, breaks_, count, sortPageValue) ->
				console.log 'sort by views'
				if err
					res.send 'No breaks found.'
				else
					res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue
		else if sortPage == 'ranking'
			console.log 'ranking function in breaks.coffee'
			breaks.sortByVotes pageNumber, sortPage, (err, breaks_, count, sortPageValue) ->
				console.log 'sort by votes'
				if err
					res.send 'No breaks found.'
				else
					res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue
		else
			breaks.findThreeRows pageNumber, sortPage, (err, breaks_, count, sortPageValue) ->
				console.log 'byDate function in breaks.coffee'
				if err
					res.send 'No breaks found.'
				else
					console.log 'count is: ' + count
					console.log 'nameSortPage is: ' + sortPageValue
					res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count: count, sortPageValue:sortPageValue

	else
		console.log 'entering search value'
		searchWord = req.body.searchValue
		sortPage = 'search'
		console.log 'change sortPage: ' + sortPage
		breaks.searchBreaks searchWord, pageNumber, sortPage, (err, breaks_, count, sortPageValue) ->
			if err
				res.send 'No breaks found.'
			else
				console.log 'render search results'
				res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue
