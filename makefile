# Start database
mongod:
	mongod --dbpath data/

# Start server
run:
	nodemon server.js

#Compile all coffee to js
compile-coffee:
	coffee --compile --output web/lib/ web/src/ && coffee --compile --output app/lib/ app/src/ && coffee -c server.coffee && coffee -c settings.coffee
