package Vornoi;
use Harbinger;
use IO::File;
use List::Util qw(min max);
use JSON;
use strict;

use constant PI => 3.14159;
my $program = "voronoi";
my %clients = ();
sub get_client {
    my ($id) = @_;
    if (!$clients{$id}) {
        $clients{$id} = {
                         pitchscale => (0.1 + rand(1.5)),
                         perimetermod => rand(2),
                        };
    }
    return $clients{$id};
}
sub register {
	my ($H,$jackit) = @_;
	$H->addHandler($program ,new
	        Harbinger::PipeHandler(
	                'open'=>((!$jackit)?"csound -dm6 -L stdin -o devaudio planets.orc planets.sco":
			                    "csound -dm6 -+rtaudio=jack -+jack_client=csoundVoronoi -o devaudio -b 400 -B 2048 -L stdin planets.orc planets.sco"),
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
        my $client = $obj->{client} || 0;
        my $clientoptions = get_client($client);
        my $pscale = $clientoptions->{pitchscale} || 1.0;
        my $pmod    = $clientoptions->{perimetermod} || 0.0;
        # narea approaches 0.05
        my $pitch = 20 + $pscale*1000* ($obj->{narea}/0.03);
        my $loudness = 1000;
        my $duration = min(0.5,($obj->{area}+1)/($pmod + $obj->{perimiter}+1));
        my $nmsg = cs("2",0.001, $duration, $loudness, $pitch);
        return ($name,$id,$dest,$nmsg);
}
1;
