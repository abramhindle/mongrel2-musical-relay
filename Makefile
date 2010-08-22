test:
	GET http://localhost:6767/handlertest
config:
	m2sh load -db myconfig.sqlite  -config myconfig.py
reload:
	m2sh reload -db myconfig.sqlite  -config myconfig.py -host localhost
start:
	m2sh start -db myconfig.sqlite -host localhost
