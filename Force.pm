package Force;
use Harbinger;
use IO::File;
use JSON;
use Data::Dumper;
use strict;

use constant PI => 3.14159;

$|=1;
my $program = "force";
my $instr_cnt=0;
my $orc = "csound/force.csd";
my $sco = "";

my %clientstate = ();

my %instrmap = (
                "fuzz" => "fuzz",
                "hiss" => "hiss",
                "squawk" => "squawk",

                "buzz" => "buzz",
                "growl" => "growl",
                "none" => "None",
                "None" => "None",
);

sub register {
	my ($H, $jackit) = @_;
	$H->addHandler($program ,new
	        Harbinger::PipeHandler(
	                'open'=>((!$jackit)?"csound -dm6 -L stdin -o devaudio $orc $sco":
			                    "csound -dm6 -+rtaudio=jack -+jack_client=csoundForce -o devaudio -b 400 -B 2048 -L stdin $orc $sco"),
	                #'open'=>'/bin/cat',
	                autoflush=>1,
	                terminator=>$/,
	                filter=>\&filterit,
	        )
	);
}
#cloned again?
sub cs {
        my ($instr,$time,$dur,@o) = @_;
        my $str = join(" ",("i$instr",(map { sprintf('%0.3f',$_) } ($time,$dur,@o)))).$/;
        return $str;
}
sub filterit {
        my ($self,$name,$id,$dest,$msg) = @_;
        my $arr =    decode_json($msg);
        my $client = $arr->{client};
        my $width =  $arr->{width}  || 500;
        my $height = $arr->{height} || 500;
        my $data =   $arr->{node}->{__data__};
        my $instr =  '"'.($instrmap{$data->{name}} || "None").'"';
        my ($dragged,$x,$y,$px,$py) = map { $data->{$_} } qw(fixed x y px py);

        warn Dumper($data, $clientstate{$client});
        my ($ldragged,$lx,$ly,$lpx,$lpy,$linstr) = map { $clientstate{$client}->{$_} } qw(fixed x y px py instr);

        # if not the same
        if (floateq($lx,$x) && floateq($ly,$y) && $instr eq $linstr) {
            return ($name,$id,$dest,"");
        } else {
            $clientstate{$client}->{instr} = $instr;
            map { 
                $clientstate{$client}->{$_} = $data->{$_};
            } qw(fixed x y px py);
        }
        my $maxdist  = sqrt( $width * $width + $height * $height );
        my $duration = 0.1;
        my $distance = sqrt(sqr($x - $px) + sqr($y - $py));
        my $loudness = min( 1000, max( 10, 1000 * $distance / $maxdist ) );
        my $nmsg = cs($instr, 0.01, $duration, $loudness, $distance, $x, $y, $px, $py, $width, $height);
        return ($name,$id,$dest,$nmsg);
}

sub sqr { $_[0] * $_[0] };

#cloned again?
sub choose { return @_[rand(@_)]; }
#cloned again?
sub min { ($_[0] > $_[1])?$_[1]:$_[0] }
sub max { ($_[0] < $_[1])?$_[1]:$_[0] }
sub floateq {
    my ($a,$b) = @_;
    return (abs($a - $b) < 0.0001);
}
1;
