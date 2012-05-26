package Vornoi;
use Harbinger;
use IO::File;
use List::Util qw(min max);
use JSON;
use strict;

use constant PI => 3.14159;
my $program = "voronoi";

sub register {
	my ($H,$jackit) = @_;
	$H->addHandler($program ,new
	        Harbinger::PipeHandler(
	                'open'=>((!$jackit)?"csound -dm6 -L stdin -o devaudio planets.orc planets.sco":
			                    "csound -dm6 -+rtaudio=jack  -o devaudio -b 400 -B 2048 -L stdin planets.orc planets.sco"),
	                autoflush=>1,
	                terminator=>$/,
	                filter=>\&filterit,
	        )
	);
}

sub cs {
        my ($instr,$time,$dur,@o) = @_;
        my $str = join(" ",("i$instr",(map { sprintf('%0.3f',$_) } ($time,$dur,@o)))).$/;
        warn $str;
        return $str;
}
sub filterit {
        my ($self,$name,$id,$dest,$msg) = @_;
        warn $msg;
        my $obj = decode_json($msg);
        # narea approaches 0.05
        my $pitch = 20 + 1000* ($obj->{narea}/0.03);
        my $loudness = 1000;
        my $duration = min(0.5,($obj->{area}+1)/($obj->{perimiter}+1));
        my $nmsg = cs("2",0.001, $duration, $loudness, $pitch);
        return ($name,$id,$dest,$nmsg);
}
1;
