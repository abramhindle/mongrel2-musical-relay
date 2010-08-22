use Harbinger;
use IO::File;
use strict;

use constant PI => 3.14159;
my $program = "bouncey";
my %balls;
my $instr_cnt=0;

my $H = Harbinger->new(port=>30666);
if ($ARGV[0] eq "-print") {
        $H->addHandler( $program ,new Harbinger::DebugHandler());
        $H->run;
        exit(0);
}
my $jackit = 0;
$H->addHandler($program ,new
        Harbinger::PipeHandler(
                'open'=>((!$jackit)?"csound -dm6 -L stdin -o devaudio planets.orc planets.sco":
		                    "csound -dm6 -+rtaudio=jack  -o devaudio -b 400 -B 1200 -L stdin planets.orc planets.sco"),
                autoflush=>1,
                terminator=>$/,
                filter=>\&wrap_filterit,
        )
);
#records the score
mkdir("scores");
my $file = "scores/".time().".sco";
my $fd = IO::File->new($file, "w+");
warn "READY";
my $then = time;

$fd->autoflush(1);
$H->run;

sub wrap_filterit {
    my ($name,$id,$dest,$smsg) = filterit(@_);
    if ($smsg) {
        foreach my $msg (split($/,$smsg)) {
            next unless $msg;
            my @parts = split(/\s+/,$msg);
            my $newtime = time - $then;
            $parts[1] += $newtime;
            $fd->print(join(" ",@parts).$/);
        }
    }
    return ($name,$id,$dest,$smsg);
}
sub cs {
        my ($instr,$time,$dur,@o) = @_;
        my $str = join(" ",("i$instr",(map { sprintf('%0.3f',$_) } ($time,$dur,@o)))).$/;
        return $str;
}
sub new_ball {
    my ($ID) = @_;
    my @instrs = qw(1902 1903);
    return {
        ID => $ID,
        x => 0,
        y => 0,
        instrument => $instrs[$instr_cnt++ % @instrs],
    }
}
sub get_ball {
    my ($ID) = @_;
    if (!exists $balls{$ID}) {
        $balls{$ID} = new_ball($ID);
    }
    return $balls{$ID};
}
sub filterit {
        my ($self,$name,$id,$dest,$msg) = @_;
        warn $msg;
        my ($ID,$ax,$ay,$bx,$by)  = split(/\s+/,$msg);
        my $ball = get_ball($ID);
        my $freq;
        my $loudness;
        my $radius = 10+rand()*100;
        my ($x,$y) = ($bx,$by);
        my $xv = $bx - $ball->{x};
        my $yv = $by - $ball->{y};
        # update ball
        $ball->{x} = $bx;
        $ball->{y} = $by;
        my $scale = 1920;
        my $sxv = $scale * $xv;
        my $syv = $scale * $yv;
        my $sx = $scale * $x;
        my $sy = $scale * $y;
        
        my $theta = atan2($xv,$yv);
        my $theta2 = atan2($x,$y);
        my $nmsg="";
        my $instrument = $ball->{instrument};#{inschoose(@instrs);#1902;#$instrs[$color % @instrs];
        my $mass = 100;
        warn $instrument;

        if ($instrument eq "1902") {
            
            $nmsg =  cs("1902",0.01,0.1 + 0.2 * abs(cos($sxv * $syv)),
                        100+2000*$theta*log(1.0 + $sxv*$sxv + $syv * $syv)/24.0,
                        (6.000 +  $theta2 / PI + 3.0 * log(1.0 + ($sxv*$sxv+$syv*$syv)/(100+$sx + $sy))/24.0),#pitch
                        0.9, 0.136, 0.45, 0.40);



            warn $nmsg;
        } elsif ($instrument eq "1903") {
            #         START  DUR    AMP      PITCH   PRESS  FILTER     EMBOUCHURE  REED TABLE
            # i 1903    0    16     6000      8.00     1.5  1000         .2            1
            my $mag = sqrt(($sxv * $sxv) + ($syv * $syv));
            #my $dur = 0.4 + 0.2 * ($xv / $mag);
            my $dur = 0.1 +  0.6 * abs(0.01+$syv) / 640.0 + 0.6 * abs(0.01+$sxv) / 640.0;
            my $amp = 10 + 2000*log(1.0+$mass * $radius * $syv * $syv)/24;
            my $pitch = 7.0 + 1.5 * $theta / PI;
            my $filter = 800 + min(20 * log($mass),300);
            my $pressure = 1.0 + 0.1 * log($mass)/30.0 + 0.9  * $theta / PI;
            $nmsg = cs("1903", 0.01, $dur,
                       $amp,
                       $pitch,
                       $pressure,
                       $filter,
                       0.2,
                       1);
        } elsif ($instrument eq "2") {
            my $duration = 0.2+$sy/32;
            my $loudness = 0.3*(100 + $sy);
            my $pitch = 10 + 100*$sx;
            my $wait = 0.001+0.2*rand();
            $nmsg = cs("1", $wait, $duration, $loudness, $pitch);
            warn $nmsg;
        }
        
        return ($name,$id,$dest,$nmsg);
        
        warn "DID NOT HANDLE: $msg";
        return ($name,$id,$dest,undef);
}
sub choose { return @_[rand(@_)]; }
sub min { ($_[0] > $_[1])?$_[1]:$_[0] }
