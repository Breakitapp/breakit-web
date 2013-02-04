# Start database
mongod:
	mongod --dbpath data/

# Start server
run:
	nodemon server.js

#Compile all and run (LOCAL)
run-l:
	make compile-coffee && NODE_ENV=local make run

#Compile all and run in prod environment
run-p:
	make compile-coffee && NODE_ENV=production forever server.js

#Compile all and run in dev environment
run-d:
	make compile-coffee && NODE_ENV=development forever server.js

# Compile all coffee to js
compile-coffee:
	coffee --compile --output web/lib/ web/src/ && coffee --compile --output app/lib/ app/src/ && coffee -c server.coffee && coffee -c settings.coffee && coffee -c scripts/migration.coffee

# Run every test!
run-tests:
	@./node_modules/.bin/mocha --compilers coffee:coffee-script --reporter spec

