# Start database
mongod:
	mongod --dbpath data/

# Start server
run:
	nodemon server.js

#Compile all and run
run-c:
	make compile-coffee && make run

# Compile all coffee to js
compile-coffee:
	coffee --compile --output web/lib/ web/src/ && coffee --compile --output app/lib/ app/src/ && coffee -c server.coffee && coffee -c settings.coffee

# Run every test!
run-tests:
	@./node_modules/.bin/mocha --compilers coffee:coffee-script --reporter spec

