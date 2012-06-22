#!/usr/bin/perl
use JSON;
use Data::Dumper;
use Parallel::ForkManager;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;
use Time::HiRes qw( gettimeofday usleep );

use strict;
$| = 1;
my $processes = shift @ARGV || 20;
my $pm = Parallel::ForkManager->new($processes);
my $replacehost = undef;

my @testfiles = <test.*>;
my %tests = ();
foreach my $file (@testfiles) {
	open(my $fd, $file);
	my @lines = <$fd>;
	close($fd);
	my @hashes = 
	grep { defined($_) } 
		map { eval { decode_json( $_ )}; } @lines;
	$tests{$file} = {
		name => $file,
		data => \@hashes,
	};
}

while(1) {
	$pm->start and next;
	my $test = $testfiles[rand(@testfiles)];
	$test = $tests{$test};
	my $data = $test->{data};
	my $ua = LWP::UserAgent->new();
	my ($starttime, $microseconds) = gettimeofday();
	foreach my $hash (@{$data}) {
		my ($nowtime, $microseconds) = gettimeofday();
		my $t = $nowtime - $starttime;
		my $htime = $hash->{dtime}->[0];
		my $hmicro = $hash->{dtime}->[1];
		my $tdiff = $htime - $t;
		if ($tdiff == 0) {
		        if ($hmicro > $microseconds) {
				usleep($hmicro - $microseconds);
			}
		} elsif ($tdiff < 0) {
		} else {
			sleep( $tdiff );
		}
		eval {
			my $req = hash2req($hash, $replacehost);
			my $res = $ua->request( $req );
			my $succ = $res->is_success;
			warn $res->is_success unless $succ == 1;
		};
		if ($@) {
			warn "ERROR  $@";
		}
	}
	$pm->finish;
}
$pm->wait_all_children;

sub hash2req {
	my ($hash, $replacehost) = @_;
	my %headers = %{$hash->{headers}};
	my $method = $headers{METHOD};
	if ($replacehost) {
		$headers{host} = $replacehost;
	}
	#warn Dumper($hash);
	my $req = HTTP::Request->new( 
		$method,
		("http://".$headers{host}.$headers{PATH}), 
		HTTP::Headers->new( %headers ),
		$hash->{body} );
	return $req;
}
