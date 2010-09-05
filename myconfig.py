from mongrel2.config import *

handler_test = Handler(send_spec='tcp://127.0.0.1:9997',
                       send_ident='82209006-86FF-4982-B5EA-D1E29E55D481',
                       recv_spec='tcp://127.0.0.1:9996',recv_ident='')

harbinger = Handler(send_spec='tcp://127.0.0.1:9967',
                    send_ident='f8144414-ad7a-11df-9185-001bfce70aad',
                     recv_spec='tcp://127.0.0.1:9966',recv_ident='')



settings = {"limits.buffer_size": 1024*1024,
            "limits.content_length": 1024*1024,
            "limits.connection_stack_size": 32*1024,
            "limits.handler_stack": 1024*1024,
            "limits.dir_send_buffer": 32*1024,
            "zeromq.threads": 1,
            }

myroute = {
              r'/tests/': Dir(base='tests/', index_file='index.html',
                             default_ctype='text/plain'),
              r'/demos/': Dir(base='harbinger-demos/', index_file='index.html',
                             default_ctype='text/plain'),
              r'/handlertest': handler_test,
              r'/harbinger': harbinger,
          }

main = Server(
    uuid="f400bf85-4538-4f7a-8908-67e313d515c2",
    access_log="/logs/access.log",
    error_log="/logs/error.log",
    chroot="./",
    default_host="localhost",
    pid_file="/run/mongrel2.pid",
    port=6767,
    hosts = [
        #Host(name="localhost", routes={
        Host(name="localhost", 
             routes=myroute,
        ),
        Host(name="192.168.0.242", 
             routes=myroute,
        ),
    ]
)

#commit([main])
commit([main], settings=settings)



