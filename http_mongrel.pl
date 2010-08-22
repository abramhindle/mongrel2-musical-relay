use strict;
use Mongrel2;
use JSON;

my $sender_id = "82209006-86FF-4982-B5EA-D1E29E55D481";
my $sub_addr = "tcp://127.0.0.1:9997";
my $pub_addr = "tcp://127.0.0.1:9996";

my $mongrel = Mongrel2::mongrel_init( $sender_id, $sub_addr, $pub_addr );


while(1) {
    print "WAITING FOR REQUEST$/";
    my $req = $mongrel->recv( );
    if ($mongrel->is_disconnect( $req )) {
        print "DICONNECT";
        next;
    }
    my $response = sprintf("<pre>\nSENDER: %s\nIDENT:%s\nPATH: %s\nHEADERS:%s\nBODY:%s</pre>",
                           $req->{sender}, 
                           $req->{conn_id},
                           $req->{path}, 
                           to_json($req->{headers}), 
                           $req->{body});

    print $response,$/;

    $mongrel->reply_http( $req, $response);
}

# Gee instead of a prefix maybe you should make a module?

