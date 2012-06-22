use strict;
use Mongrel2;
use JSON;
use IO::Socket;
use File::Temp qw/ tempfile /;
use Time::HiRes qw( gettimeofday );

my $sender_id = "f8144414-ad7a-11df-9185-001bfce70aad";
my $sub_addr = "tcp://127.0.0.1:9967";
my $pub_addr = "tcp://127.0.0.1:9966";

my $mongrel = Mongrel2::mongrel_init( $sender_id, $sub_addr, $pub_addr );

my $sock = IO::Socket::INET->new(
   Proto    => 'udp',
   PeerPort => 30666,
   PeerAddr => '127.0.0.1',
) or die "Could not create socket: $!\n";


# {program:"program name", id:"", dest:"", msg:""}
sub relay_harb {
    my ($sock,$h) = @_;
    my $msg = join("|",$h->{program}, ($h->{id} || ""), ($h->{dest}||""), $h->{msg});
    warn "Sending $msg";
    $sock->send( $msg ) or warn "Send Error: $!\n";
}
my $cnt=0;
my ($fh,$filename) = tempfile();
warn $filename;
my ($starttime, $_) = gettimeofday();
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
	my ($nowtime, $microseconds) = gettimeofday();
	$req->{dtime} = [$nowtime - $starttime, $microseconds];
	print $fh encode_json($req);
	print $fh $/;
        if ($req->{body}) {
            eval {
                my $code = from_json( $req->{body} );
                relay_harb( $sock, $code );
            };
            if ($@) {
                $mongrel->reply_http( $req, "COULD NOT SEND $cnt");
            } else {
                $mongrel->reply_http( $req, "<ok/>");# $cnt");
            }
        } else {
            $mongrel->reply_http( $req, "NO BODY $cnt");
        }
        #$mongrel->reply_http( $req, $response);
    }
}


# Gee instead of a prefix maybe you should make a module?

