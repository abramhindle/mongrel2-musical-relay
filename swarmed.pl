use strict;
use Mongrel2;
use JSON;
use IO::Socket;
use Data::Dumper;
use POSIX qw(floor);
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

my $startime = undef;
# hack per minute
my @timeline = (
                [0 ,qw(button tableforce force)],
                [2 ,qw(button tableforce force voronoi)],
                [4 ,qw(button tableforce force voronoi bouncey)],
                [6 ,qw(button voronoi bouncey env)],
                [8 ,qw(button voronoi bouncey env cloth)],
                [10,qw(button voronoi bouncey env cloth)],
                [12,qw(env tableforce force)],
);


my %apps = (
            force => {
                      name => "Force",
                      url => "$route_addr/demos/force_files/force.html",
                      allowed => $notandroid2,
                     },
            voronoi => {
                      name => "Voronoi",
                      url => "$route_addr/demos/voronoi/voronoi.html",
                      allowed => $notandroid2,
                     },
            tableforce => {
                      name => "Blocks",
                      url => "$route_addr/demos/tableforce/tableforce.html",
                      allowed => $dfl,
                     },

            bouncey => {
                        name => "Bouncey",
                        url => "$route_addr/demos/bouncey.html",
                        allowed => $dfl,
                       },
            cloth => {
                      name => "Cloth",
                      url => "$route_addr/demos/cloth.html",
                      allowed => $dfl,
                     },
            button => {
                      name => "Virtual Triangle",
                      url => "$route_addr/demos/button.html",
                      allowed => $dfl,
                     },
            env => {
                      name => "Envelope",
                      url => "/demos/envelope.html",
                      allowed => $dfl,
                     },

);

my @allchoices = keys %apps;

my $starttime = undef;

sub choose {
    my $ua = shift;
    my $choice = undef;
    my @choices = @allchoices;
    if (defined($starttime)) {
        my $minutes = (time() - $starttime) / 60;
        warn $minutes;
        for my $time (@timeline) {
            my ($t,@a) = @$time;
            if ($t <= $minutes) {
                @choices = @a;
            } else {
                last;
            }
        }
    }
    warn "Limited to ".join(", ", @choices);
    while (!defined($choice)) {
        my $possible = $choices[rand(@choices)];
        my $app = $apps{$possible};
        if (&{$app->{allowed}}( $ua )) {
            $choice = $possible;
        }
    }
    return $choice;
}


open(my $fd,"404/index.html");
my @lines = <$fd>;
close($fd);
my $responsehtml = join("", @lines);



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
        my $path = $req->{'path'};
        if ($path =~ /startperformance/) {
            if (!defined($starttime) || (time() - $starttime) > 5*60) {
                $starttime = time();
            }
        }
        my $choice = choose( $ua );
        my $response = redirect( $apps{$choice}, $host );

        $mongrel->reply_http( $req, $response );
    }
}

#sub redirect {
#    my ($choice) = @_;
#    my %choice = %$choice;
#    my $html = $responsehtml;
#    $html =~ s/%TITLE%/$choice{name}/g;
#    $html =~ s/%URL%/$choice{url}/g;
#    return $html;
#}
sub redirect {
    my ($choice, $host) = @_;
    my %choice = %$choice;
    my $html = $responsehtml;
    if (!$host) {
        $host = $route_addr;
    } else {
        if ($host =~ /http:\/\//) {

	} else {
            $host = "http://$host";
        }
    }
    $host ||= $route_addr;
    my $url = $host . $choice{url};
    $html =~ s/%TITLE%/$choice{name}/g;
    $html =~ s/%URL%/$choice{url}/g;
    return $html;
}
