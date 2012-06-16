package Force;
use Harbinger;
use IO::File;
use JSON;
use strict;

use constant PI => 3.14159;
$|=1;
my $program = "force";
my $instr_cnt=0;
my $orc = "csound/force.csd";
my $sco = "";
my %instrmap = (
                "fuzz" => "fuzz",
                "hiss" => "hiss",
                "squawk" => "squawk",
                "buzz" => "buzz",
                "growl" => "growl",
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
        my $arr =    from_json($msg);
        my $client = $arr->{client};
        my $width =  $arr->{width}  || 500;
        my $height = $arr->{height} || 500;
        my $obj =    $arr->{node};
        my $data =   $obj->{_data__};
        my $instr =  $instrmap{$data->{name}} || "hiss";
        my ($dragged,$x,$y,$px,$py) = map { $data->{$_} } qw(fixed x y px py);
        my $duration = 0.1;
        my $distance = sqrt(sqr($x - $px) + sqr($y - $py));
        my $loudness = min(1000,max(10, $distance));
        my $nmsg = cs($instr, 0.01, $duration, $loudness, $distance, $x, $y, $px, $py, $width, $height);
        return ($name,$id,$dest,$nmsg);
}

sub sqr { $_[0] * $_[0] };

#cloned again?
sub choose { return @_[rand(@_)]; }
#cloned again?
sub min { ($_[0] > $_[1])?$_[1]:$_[0] }
1;
