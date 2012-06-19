use strict;
use Mongrel2;
use JSON;
use IO::Socket;

my $sender_id = "bcd0e1af-b05c-43ea-a4a8-f589b555c867";

my $sub_addr = "tcp://127.0.0.1:9977";
my $pub_addr = "tcp://127.0.0.1:9978";

my $mongrel = Mongrel2::mongrel_init( $sender_id, $sub_addr, $pub_addr );

open(my $fd,"404/index.html");
my @lines = <$fd>;
close($fd);
my $response = "404.pl: ".join("", @lines);


while(1) {
    print "WAITING FOR REQUEST$/";
    my $req = $mongrel->recv( );
    if ($mongrel->is_disconnect( $req )) {
        print "DISCONNECT";
        next;
    } else {
        $mongrel->reply_http( $req, $response);
    }
}


