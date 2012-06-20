test:
	GET http://localhost:6767/handlertest
config: myconfig.conf
	m2sh load -db myconfig.sqlite  -config myconfig.conf
reload: myconfig.conf
	m2sh reload -db myconfig.sqlite  -config myconfig.conf -host localhost
start:
	mkdir run || echo lol
	sudo privbind -u `whoami` -n 1 m2sh start -db myconfig.sqlite -host localhost

tests:
	GET http://localhost:6767/tests/sample.html
	GET http://localhost:6767/tests/index.html
	GET http://localhost:6767/tests/index.html
