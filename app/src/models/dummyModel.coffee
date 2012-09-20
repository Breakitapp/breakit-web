#Dummy data for Breakit

breakModel = require './breakModel'
userModel = require './userModel'
albumModel = require './albumModel'

#Create dummydata

#Users

user1 = new userModel.User 1, 'Seppo', 'Taalasmaa', 'Sepi', 'sepi@talonmies.com', 'nokia 6510'
user2 = new userModel.User 2, 'Ismo', 'Laitela', 'Iso-Ismo', 'ismo@turpaan.com', 'Benefon i'
user3 = new userModel.User 3, 'Hra', 'Hakkarainen', 'hh', 'hakkarainen@koirala.com', 'Mutsis luuri, lol'

user1.save ->
user2.save ->
user3.save ->

#Breaks

break1 = new breakModel.Break 1, 65, 64, 'Shangri-La', 'Here be something fun', 'Chillin at Shangri-la'
break2 = new breakModel.Break 2, 62, 61, 'Hobocave', 'Hobos', 'Damn nigga, it smells here!'
break3 = new breakModel.Break 3, 65.6, 64.9, 'Queens palace', 'Walking the corgis', 'I was walking the queens corgis, when suddenly Daniel Craig rushed us and kidnapped the dogs. Please, someone, HALP!'
break4 = new breakModel.Break 4, 72, 4, 'Venture Garage', 'BBQ', 'BBQ at the new venture garage'
break5 = new breakModel.Break 5, 10, 50, 'dipoli', 'Here be something fun', 'Chillin at Dipoli'
break6 = new breakModel.Break 6, 4, 15, 'Poopville', 'hihihihihihi', 'pooop'
break7 = new breakModel.Break 7, 62, 69, 'Boobville', 'hihihihihih', 'Boob'
break8 = new breakModel.Break 8, 63, 60, 'Shangri-La', 'Again @ shangri-la', 'Chillin at Shangri-la'

break1.save user1
break2.save user2
break3.save user3
break4.save user1
break5.save user2
break6.save user3
break7.save user1
break8.save user2

#Albums

album1 = new albumModel.Album 'venture garage'
album2 = new albumModel.Album 'by'

album1.save (id) ->
	album1.dbid = id
	console.log album1.dbid
album2.save (id) ->
	album2.dbid = id
	console.log album2.dbid

console.log 'waiting muthafucka'
console.log album1.dbid
console.log album2.dbid
albumModel.addBreak album1.dbid, break1
albumModel.addBreak album2.dbid, break2
albumModel.addBreak album1.dbid, break3
albumModel.addBreak album2.dbid, break4
albumModel.addBreak album1.dbid, break5
albumModel.addBreak album2.dbid, break6
albumModel.addBreak album1.dbid, break7
albumModel.addBreak album2.dbid, break8

setTimeout 'lol', 200

#albumModel.remove album2.dbid
