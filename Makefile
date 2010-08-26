test:
	GET http://localhost:6767/handlertest
config:
	m2sh load -db myconfig.sqlite  -config myconfig.py
reload:
	m2sh reload -db myconfig.sqlite  -config myconfig.py -host localhost
start:
	mkdir run || echo lol
	m2sh start -db myconfig.sqlite -host localhost

tests:
	GET http://localhost:6767/tests/sample.html
	GET http://localhost:6767/tests/index.html
	GET http://localhost:6767/tests/index.html
