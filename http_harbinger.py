from mongrel2 import handler
import json

sender_id = "f8144414-ad7a-11df-9185-001bfce70aad"

conn = handler.Connection(sender_id, "tcp://127.0.0.1:9967",
                          "tcp://127.0.0.1:9966")
while True:
    print "WAITING FOR REQUEST"

    req = conn.recv()

    if req.is_disconnect():
        print "DICONNECT"
        continue

    response = "<pre>\nSENDER: %r\nIDENT:%r\nPATH: %r\nHEADERS:%r\nBODY:%r</pre>" % (
        req.sender, req.conn_id, req.path, 
        json.dumps(req.headers), req.body)

    print response

    conn.reply_http(req, response)

