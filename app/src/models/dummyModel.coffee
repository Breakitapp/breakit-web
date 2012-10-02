async = require "async"

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

#Albums
album1 = new albumModel.Album 'by'
album1.save()

#Breaks
data = lon : 65, lat : 65, location_name : 'by', story : 'mutha<fucka', headline : 'booo', user: user1

breakModel.createBreak data, (err, docs) ->
	console.log docs
	console.log album1.breaks

###
break1 = new breakModel.Break  65, 64, 'Shangri-La', 'Here be something fun', 'Chillin at Shangri-la'
break2 = new breakModel.Break  62, 61, 'Hobocave', 'Hobos', 'Damn nigga, it smells here!'
break3 = new breakModel.Break  65.6, 64.9, 'Queens palace', 'Walking the corgis', 'I was walking the queens corgis, when suddenly Daniel Craig rushed us and kidnapped the dogs. Please, someone, HALP!'
break4 = new breakModel.Break  72, 4, 'Venture Garage', 'BBQ', 'BBQ at the new venture garage'
break5 = new breakModel.Break  10, 50, 'dipoli', 'Here be something fun', 'Chillin at Dipoli'
break6 = new breakModel.Break  4, 15, 'Poopville', 'hihihihihihi', 'pooop'
break7 = new breakModel.Break  62, 69, 'Boobville', 'hihihihihih', 'Boob'
break8 = new breakModel.Break  63, 60, 'Shangri-La', 'Again @ shangri-la', 'Chillin at Shangri-la'
break9 = new breakModel.Break  65, 64, 'Shangri-La', 'Here be something fun', 'Chillin at Shangri-la'
break10 = new breakModel.Break  62, 61, 'Hobocave', 'Hobos', 'Damn nigga, it smells here!'
break11 = new breakModel.Break  65.6, 64.9, 'Queens palace', 'Walking the corgis', 'I was walking the queens corgis, when suddenly Daniel Craig rushed us and kidnapped the dogs. Please, someone, HALP!'
break12 = new breakModel.Break  72, 4, 'Venture Garage', 'BBQ', 'BBQ at the new venture garage'
break13 = new breakModel.Break  10, 50, 'dipoli', 'Here be something fun', 'Chillin at Dipoli'
break14 = new breakModel.Break  4, 15, 'Poopville', 'hihihihihihi', 'pooop'
break15 = new breakModel.Break  62, 69, 'Boobville', 'hihihihihih', 'Boob'
break16 = new breakModel.Break  63, 60, 'Shangri-La', 'Again @ shangri-la', 'Chillin at Shangri-la'
break17 = new breakModel.Break  65, 64, 'Shangri-La', 'Here be something fun', 'Chillin at Shangri-la'
break18 = new breakModel.Break 62, 61, 'Hobocave', 'Hobos', 'Damn nigga, it smells here!'
break19 = new breakModel.Break  65.6, 64.9, 'Queens palace', 'Walking the corgis', 'I was walking the queens corgis, when suddenly Daniel Craig rushed us and kidnapped the dogs. Please, someone, HALP!'
break20 = new breakModel.Break  72, 4, 'Venture Garage', 'BBQ', 'BBQ at the new venture garage'
break21 = new breakModel.Break  10, 50, 'dipoli', 'Here be something fun', 'Chillin at Dipoli'
break22 = new breakModel.Break 4, 15, 'Poopville', 'hihihihihihi', 'pooop'
break23 = new breakModel.Break  62, 69, 'Boobville', 'hihihihihih', 'Boob'
break24 = new breakModel.Break  63, 60, 'Shangri-La', 'Again @ shangri-la', 'Chillin at Shangri-la'
break25 = new breakModel.Break  65, 64, 'Shangri-La', 'Here be something fun', 'Chillin at Shangri-la'
break26 = new breakModel.Break  62, 61, 'Hobocave', 'Hobos', 'Damn nigga, it smells here!'
break27 = new breakModel.Break  65.6, 64.9, 'Queens palace', 'Walking the corgis', 'I was walking the queens corgis, when suddenly Daniel Craig rushed us and kidnapped the dogs. Please, someone, HALP!'
break28 = new breakModel.Break  72, 4, 'Venture Garage', 'BBQ', 'BBQ at the new venture garage'
break29 = new breakModel.Break  10, 50, 'dipoli', 'Here be something fun', 'Chillin at Dipoli'
break30 = new breakModel.Break  4, 15, 'Poopville', 'hihihihihihi', 'pooop'
break31 = new breakModel.Break  62, 69, 'Boobville', 'hihihihihih', 'Boob'
break32 = new breakModel.Break  63, 60, 'Shangri-La', 'Again @ shangri-la', 'Chillin at Shangri-la'

album1 = new albumModel.Album 'venture garage'
album2 = new albumModel.Album 'Breakit HQ'

album1.save (id) ->
	album1.dbid = id
	console.log 'album1: ' + album1.dbid
album2.save (id) ->
	album2.dbid = id
	console.log 'album2: ' + album2.dbid
	
console.log 'waiting muthafucka'
setTimeout 'lol', 2000

console.log album1.dbid # null
console.log album2.dbid # null

break1.save user1
break2.save user2
break3.save user3
break4.save user1
break5.save user2
break6.save user3
break7.save user1
break8.save user2
break9.save user1
break10.save user2
break11.save user3
break12.save user1
break13.save user2
break14.save user3
break15.save user1
break16.save user2
break17.save user1
break18.save user2
break19.save user3
break20.save user1
break21.save user2
break22.save user3
break23.save user1
break24.save user2
break25.save user1
break26.save user2
break27.save user3
break28.save user1
break29.save user2
break30.save user3
break31.save user1
break32.save user2

setTimeout 'lol', 200


###
#Albums
###

albumModel.addBreak album1.dbid, break1
albumModel.addBreak album2.dbid, break2
albumModel.addBreak album1.dbid, break3
albumModel.addBreak album2.dbid, break4
albumModel.addBreak album1.dbid, break5
albumModel.addBreak album2.dbid, break6
albumModel.addBreak album1.dbid, break7
albumModel.addBreak album2.dbid, break8

setTimeout 'lol', 200


###
#albumModel.remove album2.dbid
