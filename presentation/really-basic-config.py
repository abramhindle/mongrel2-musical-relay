main = Server(
  uuid="cd27a9c2-386b-4b51-b21e-3e5635a94551",
  access_log="/logs/access.log",
  error_log="/logs/error.log",
  chroot="./",
  default_host="localhost",
  pid_file="/run/mongrel2.pid",
  port=6767,
  hosts = [ Host(name="localhost", routes=myroute) ]
)
commit([main])
