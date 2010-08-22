use strict;
use HTTP::Request;
use JSON;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new;
my $txt = join(" ", @ARGV);
my $msg = to_json({
                   program => "bodypost",
                   msg => $txt,
                   });
#my $req = HTTP::Request->new( GET => "http://localhost:6767/handlertest");
my $req = HTTP::Request->new( GET => "http://localhost:6767/harbinger");
$req->content( $msg );
my $response = $ua->request( $req );
warn $response->code;
print $response->content;
