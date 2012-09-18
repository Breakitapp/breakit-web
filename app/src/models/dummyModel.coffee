#Dummy data for Breakit

breakModel = require './breakModel'
userModel = require './userModel'

#Create dummydata

#Users

user1 = new userModel.User 'Seppo', 'Taalasmaa', 'Sepi', 'sepi@talonmies.com', 1
user2 = new userModel.User 'Ismo', 'Laitela', 'Iso-Ismo', 'ismo@turpaan.com', 2
user3 = new userModel.User 'Hra', 'Hakkarainen', 'hh', 'hakkarainen@koirala.com', 3

user1.save ->
user2.save ->
user3.save ->

#Breaks

break1 = new breakModel.Break 1, 65, 64, 'Shangri-La', 'Here be something fun', 'Chillin at Shangri-la'
break2 = new breakModel.Break 2, 62, 61, 'Hobocave', 'Hobos', 'Damn nigga, it smells here!'
break3 = new breakModel.Break 3, 65.6, 64.9, 'Queens palace', 'Walking the corgis', 'I was walking the queens corgis, when suddenly Daniel Craig rushed us and kidnapped the dogs. Please, someone, HALP!'
break4 = new breakModel.Break 4, 72, 4, 'Venture Garage', 'BBQ', 'BBQ at the new venture garage'
break5 = new breakModel.Break 5, 10, 100, 'dipoli', 'Here be something fun', 'Chillin at Dipoli'
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
