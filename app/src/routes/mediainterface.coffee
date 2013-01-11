breaks = require '../models/breakModel'

#This renders the index of mediainterface
exports.mediaInterface= (req, res) ->
	console.log 'entering Media Interface'
	#checks which page the user wishes to go to
	pageNumber = req.body.pageNumber
	
	#Checks which is the sort method currently in use
	currentSortPage = req.body.currentSortPage
	
	#Checks if user has chosen a new sort method
	sortPage = req.body.sortPage
	
	#if no sortmethod is chosen the sortmethod is set to by date
	if sortPage == undefined && currentSortPage == undefined
		sortPage = 'byDate'
	
	#if there is a current sorthmethod in use this overrides the by date sortment
	else if sortPage == undefined
		sortPage = currentSortPage
	console.log 'sortPage variable is: ' + sortPage
	
	#If a pagenumber hasn't been defined it defaults to the first page
	if pageNumber == undefined
		pageNumber = 0
	
	#the page number is decreased by one so that the first page is 0 second is 1 and so on
	else if pageNumber > 0
		pageNumber -= 1
	console.log 'testing searchValue: ' + req.body.searchValue
	console.log 'page number: ' + pageNumber
	
	#checks if the requirements for the search function are fullfilled
	if req.body.searchValue == undefined  && sortPage != 'search' || req.body.searchValue == 'search' && sortPage != 'search'
		console.log 'search function skipped'
		sortFunctions = 
			commented: breaks.sortByComments
			viewed: breaks.sortByViews
			ranking: breaks.sortByVotes
			byDate: breaks.findThreeRows
				
		sortFunction = sortFunctions[sortPage]
		sortFunction pageNumber, sortPage, (err, breaks_, count, sortPageValue) ->
			console.log 'sort by comments'
			if err
				res.send 'No breaks found.'
			else
				res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue
				

		#Determinates which sort function to launch
		###			
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
###
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
