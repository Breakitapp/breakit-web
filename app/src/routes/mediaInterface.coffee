breaks = require '../models/breakModel'

#This renders the index of mediainterface
exports.mediaInterface= (req, res) ->
	console.log 'entering Media Interface'
	
	#Checks which is the sort method currently in use
	currentSortPage = req.body.currentSortPage
	
	#Checks if user has chosen a new sort method
	sortPage = req.body.sortPage
	
	#if no sort method is chosen the sortmethod is set to by date
	if sortPage == undefined && currentSortPage == undefined
		sortPage = 'byDate'
	
	#if there is a current sort method in use this overrides the current sort method
	else if sortPage == undefined
		sortPage = currentSortPage
	console.log 'sortPage variable is: ' + sortPage
	
		#checks which page the user wishes to go to
	pageNumber = req.body.pageNumber
	pageNumber = parseInt pageNumber
	console.log pageNumber

	#If a pagenumber hasn't been defined it defaults to the first page
	if pageNumber is undefined || pageNumber == 0
		pageNumber = 0
		console.log 'page number set to 0: ' + pageNumber
	else
		#otherwise the pageNumber is increased with 1
		pageNumber += 1
		console.log 'page number is now: ' + pageNumber
	
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
				throw err
			else
				res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue, pageNumber:pageNumber
				
	else
		console.log 'entering search value'
		searchWord = req.body.searchValue
		sortPage = 'search' 
		console.log 'change sortPage: ' + sortPage
		#Start the searchfunction for the wanted breaks. Search funtion needs an extra variable called searchWord that contains the value of the word searched after
		#TODO:pages wont work while the whole page renders itself leaving the search box value undefined
		breaks.searchBreaks searchWord, pageNumber, sortPage, (err, breaks_, count, sortPageValue, searchWord) ->
			if err
				throw err
			else
				console.log 'render search results'
				if sortPageValue is undefined
						sortPageValue = 'search'
				if searchWord is undefined
						searchWord = req.body.searchValue
				res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue, searchWord:searchWord, pageNumber:pageNumber
