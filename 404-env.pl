use strict;
use Mongrel2;
use JSON;
use IO::Socket;
use Data::Dumper;
my $sender_id = "bcd0e1af-b05c-43ea-a4a8-f589b555c867";

my $sub_addr = "tcp://127.0.0.1:9977";
my $pub_addr = "tcp://127.0.0.1:9978";
my $route_addr = "http://10.20.30.1";

my $mongrel = Mongrel2::mongrel_init( $sender_id, $sub_addr, $pub_addr );

# everything is ok
my $dfl = sub { return 1; };

# no android 1-2 clients
my $notandroid2 = sub {
    my $ua = shift;
    if ($ua =~ /android [12]/i) {
        return 0;
    }
    return 1;
};

# no android clients
my $notandroid = sub {
    my $ua = shift;
    if ($ua =~ /android/i) {
        return 0;
    }
    return 1;
};
# no iphone clients
my $notiphone = sub {
    my $ua = shift;
    if ($ua =~ /iphone/i) {
        return 0;
    }
    return 1;
};


my $notphone = sub {
	my ($ua) = @_;
	return &{$notandroid}($ua) && &{$notiphone}($ua);
};


my %apps = (
            env => {
                      name => "Envelope",
                      url => "$route_addr/demos/envelope.html",
                      allowed => $dfl,
                     }
);


open(my $fd,"404/index.html");
my @lines = <$fd>;
close($fd);
my $responsehtml = join("", @lines);

my @choices = keys %apps;

while(1) {
    print "WAITING FOR REQUEST$/";
    my $req = $mongrel->recv( );
    if ($mongrel->is_disconnect( $req )) {
        print "DISCONNECT";
        next;
    } else {
        my $ua = $req->{'headers'}->{'user-agent'};
	warn $ua;
        my $host = $req->{'headers'}->{'host'};
        my $choice = undef;
        while (!defined($choice)) {            
            my $possible = $choices[rand(@choices)];
            my $app = $apps{$possible};
            if (&{$app->{allowed}}( $ua )) {
                $choice = $possible;
            }
        }

        my $response = redirect( $apps{$choice} );

        $mongrel->reply_http( $req, $response );
    }
}

sub redirect {
    my ($choice) = @_;
    my %choice = %$choice;
    my $html = $responsehtml;
    $html =~ s/%TITLE%/$choice{name}/g;
    $html =~ s/%URL%/$choice{url}/g;
    return $html;
}
