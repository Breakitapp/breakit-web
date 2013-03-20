breaks = require '../models/breakModel'
userModel = require '../models/userModel'

#This renders the index of mediainterface
exports.mediaInterface= (req, res) ->
	console.log 'entering Media Interface'
	
	#check for query objects to direct the user to the right page
	queryObject = require('url').parse(req.url,true).query
	
	#Checks which is the sort method currently in use
	currentSortPage = req.body.currentSortPage
	
	#Checks if user has chosen a new sort method
	sortPage = req.body.sortPage
	
	#if no sort method is chosen the sortmethod is set to date
	if sortPage == undefined && currentSortPage == undefined
		sortPage = 'date'
	
	#if there is a current sort method in use the sortPage is redefined to the old sort method
	else if sortPage == undefined
		sortPage = currentSortPage
	console.log 'sortPage variable is: ' + sortPage
	
	#check if query for existing page number exists
	if typeof queryObject.page is 'undefined'
		#checks which page the user wishes to go to
		pageNumber = req.body.pageNumber
		pageNumber = parseInt pageNumber
	else
		#if pagenumber is the number recieved from the query the user is dericted to the existing page
		pageNumber = queryObject.page-1
		console.log 'The query page is: ' + pageNumber
	console.log 'test query: ' + pageNumber
	
	#If a pagenumber hasn't been defined it defaults to the first page
	if isNaN(pageNumber) or pageNumber is undefined or pageNumber < 0
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
			date: breaks.findMediaRows
		
		#Get the wanted function with the searchword sortPage		
		sortFunction = sortFunctions[sortPage]
		
		#Start the wanted function
		sortFunction pageNumber, sortPage, (err, breaks_, count, sortPageValue) ->
			console.log 'sort by ' + sortPage
			if err
				throw err
			else
				console.log 'pageNumber before rendering: ' + pageNumber
				res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue, pageNumber:pageNumber
				
	else
		console.log 'entering search value'
		searchWord = req.body.searchValue
		sortPage = 'search' 
		console.log 'change sortPage: ' + sortPage
		#Start the searchfunction for the wanted breaks. Search funtion needs an extra variable called searchWord that contains the value of the word searched after
		breaks.searchBreaks searchWord, pageNumber, sortPage, (err, breaks_, count, sortPageValue, searchWord) ->
			if err
				throw err
			else
				console.log 'render search results'
				if sortPageValue is undefined
						sortPageValue = 'search'
				if searchWord is undefined
						searchWord = req.body.searchValue
				console.log 'pageNumber before rendering: ' + pageNumber
				res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue, searchWord:searchWord, pageNumber:pageNumber


exports.login = (req, res) ->
	res.render 'adminlogin_mediaInterface', title: 'Breakit admin login'
	
exports.view = (req, res) ->
	if String(req.body.admincode) is "d0lph1n" #hardcoded password atm. TODO: make the admin authentication properly
		users = userModel.list (u) ->
			console.log 'users in mediainterface: ' + u
			res.render 'mediaInterfaceUsers', title : 'Feedback test form', users: u

exports.loginAsAdmin = (req, res) ->
	if String(req.body.admincode) is "d0lph1n"
		console.log 'entering Media Interface as ADMIN'
		console.log 'req.body: '+req.body
		console.log 'req.body.userId: '+req.body.userId
		
		console.log 'entering Media Interface'
		
		#check for query objects to direct the user to the right page
		queryObject = require('url').parse(req.url,true).query
		
		#Checks which is the sort method currently in use
		currentSortPage = req.body.currentSortPage
		
		#Checks if user has chosen a new sort method
		sortPage = req.body.sortPage
		
		#if no sort method is chosen the sortmethod is set to date
		if sortPage == undefined && currentSortPage == undefined
			sortPage = 'date'
		
		#if there is a current sort method in use the sortPage is redefined to the old sort method
		else if sortPage == undefined
			sortPage = currentSortPage
		console.log 'sortPage variable is: ' + sortPage
		
		#check if query for existing page number exists
		if typeof queryObject.page is 'undefined'
			#checks which page the user wishes to go to
			pageNumber = req.body.pageNumber
			pageNumber = parseInt pageNumber
		else
			#if pagenumber is the number recieved from the query the user is dericted to the existing page
			pageNumber = queryObject.page-1
			console.log 'The query page is: ' + pageNumber
		console.log 'test query: ' + pageNumber
		
		#If a pagenumber hasn't been defined it defaults to the first page
		if isNaN(pageNumber) or pageNumber is undefined or pageNumber < 0
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
				date: breaks.findMediaRows
			
			#Get the wanted function with the searchword sortPage		
			sortFunction = sortFunctions[sortPage]
			
			#Start the wanted function
			sortFunction pageNumber, sortPage, (err, breaks_, count, sortPageValue) ->
				console.log 'sort by ' + sortPage
				if err
					throw err
				else
					console.log 'pageNumber before rendering: ' + pageNumber
					res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue, pageNumber:pageNumber, user: req.body.userId, admincode: 'd0lph1n'
					
		else
			console.log 'entering search value'
			searchWord = req.body.searchValue
			sortPage = 'search' 
			console.log 'change sortPage: ' + sortPage
			#Start the searchfunction for the wanted breaks. Search funtion needs an extra variable called searchWord that contains the value of the word searched after
			breaks.searchBreaks searchWord, pageNumber, sortPage, (err, breaks_, count, sortPageValue, searchWord) ->
				if err
					throw err
				else
					console.log 'render search results'
					if sortPageValue is undefined
							sortPageValue = 'search'
					if searchWord is undefined
							searchWord = req.body.searchValue
					console.log 'pageNumber before rendering: ' + pageNumber
					res.render 'mediaInterface', title : 'Breakit ', breaks: breaks_, count:count, sortPageValue:sortPageValue, searchWord:searchWord, pageNumber:pageNumber, user:req.body.userId, admincode: 'd0lph1n'
