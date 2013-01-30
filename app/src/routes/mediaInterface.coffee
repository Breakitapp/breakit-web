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
		#An array to keep all the function calls in one place
		sortFunctions = 
			commented: breaks.sortByComments
			viewed: breaks.sortByViews
			ranking: breaks.sortByVotes
			byDate: breaks.findMediaRows
		
		#Get the wanted function with the searchword sortPage		
		sortFunction = sortFunctions[sortPage]
		
		#Start the wanted function
		sortFunction pageNumber, sortPage, (err, breaks_, count, sortPageValue) ->
			console.log 'sort by comments'
			if err
				res.send 'No breaks found.'
			else
				res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue
				
	else
		console.log 'entering search value'
		searchWord = req.body.searchValue
		sortPage = 'search' 
		console.log 'change sortPage: ' + sortPage
		#Start the searchfunction for the wanted breaks. Search funtion needs an extra variable called searchWord that contains the value of the word searched after
		#TODO:pages wont work while the whole page renders itself leaving the search box value undefined
		breaks.searchBreaks searchWord, pageNumber, sortPage, (err, breaks_, count, sortPageValue) ->
			if err
				res.send 'No breaks found.'
			else
				console.log 'render search results'
				if sortPageValue is undefined
						sortPageValue = 'search'
				res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue
