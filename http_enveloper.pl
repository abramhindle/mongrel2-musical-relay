#!/usr/bin/perl
use strict;
use Mongrel2;
use JSON;
use Harbinger;
use Enveloper;
use IO::Socket;

my $sender_id = "304de55b-7c8b-4aec-95f9-70450c90f9aa";

my $sub_addr = "tcp://127.0.0.1:9987";
my $pub_addr = "tcp://127.0.0.1:9986";

my $mongrel = Mongrel2::mongrel_init( $sender_id, $sub_addr, $pub_addr );

# my $sock = IO::Socket::INET->new(
#    Proto    => 'udp',
#    PeerPort => 30666,
#    PeerAddr => '127.0.0.1',
# ) or die "Could not create socket: $!\n";
# 
my $H = Harbinger->new();
my $jackit = 1;
use Enveloper;
Enveloper::register($H, $jackit);


# {program:"program name", id:"", dest:"", msg:""}
sub relay_harb {
    my ($h) = @_;
    $H->handle($h->{program}, $h->{id}, $h->{dest}, $h->{msg});

    #my $msg = join("|",$h->{program}, ($h->{id} || ""), ($h->{dest}||""), $h->{msg});

    #warn "Sending $msg";
    #$sock->send( $msg ) or warn "Send Error: $!\n";
}
my $cnt=0;
while(1) {
    print "WAITING FOR REQUEST$/";
    my $req = $mongrel->recv( );
    if ($mongrel->is_disconnect( $req )) {
        print "DISCONNECT";
        next;
    } else {
        #my $response = sprintf("<pre>\nSENDER: %s\nIDENT:%s\nPATH: %s\nHEADERS:%s\nBODY:%s</pre>",
        #                   $req->{sender}, 
        #                   $req->{conn_id},
        #                   $req->{path}, 
        #                   to_json($req->{headers}), 
        #                   $req->{body});

        print $cnt++.$/;#.$response.$/;
        if ($req->{body}) {
            eval {
                my $code = from_json( $req->{body} );
                relay_harb( $code );
            };
            if ($@) {
                $mongrel->reply_http( $req, "COULD NOT SEND $cnt");
            } else {
                # now get state and return it
                # step 1. naively keep returning the state back to the user
                my $state = Enveloper::get_state();
                my $str = encode_json($state);
                $mongrel->reply_http( $req, $str);
            }
        } else {
            $mongrel->reply_http( $req, "NO BODY $cnt");
        }
        #$mongrel->reply_http( $req, $response);
    }
}


# Gee instead of a prefix maybe you should make a module?

