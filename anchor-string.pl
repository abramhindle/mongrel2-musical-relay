use Harbinger;
use IO::File;
use JSON;
use strict;

use constant PI => 3.14159;
$|=1;
my $program = "anchor";
my %bugs;
my $instr_cnt=0;
my $maxloud = 16000/100.0;
my $HEIGHT = 10;
my $jackit = $ENV{JACKIT} || 0;
my $orc = "csound/bowed_string.csd";
my $sco = "";
my %points = ();
my $H = Harbinger->new(port=>30666);
if ($ARGV[0] eq "-print") {
        $H->addHandler( $program ,new Harbinger::DebugHandler());
        $H->run;
        exit(0);
}
$H->addHandler($program ,new
        Harbinger::PipeHandler(
                'open'=>((!$jackit)?"csound -dm6 -L stdin -o devaudio $orc $sco":
		                    "csound -dm6 -+rtaudio=jack  -o devaudio -b 400 -B 1200 -L stdin $orc $sco"),
                #'open'=>'/bin/cat',
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

#cloned again?
sub wrap_filterit {
    my ($self,$name,$id,$dest,$msg) = @_;
    my ($name,$id,$dest,$smsg) = filterit($self, $name, $id, $dest, $msg);
    if ($smsg) {
        foreach my $msg (split($/,$smsg)) {
            next unless $msg;
            warn $msg;
            my @parts = split(/\s+/,$msg);
            my $newtime = time - $then;
            $parts[1] += $newtime;
            $fd->print(join(" ",@parts).$/);
        }
    }
    return ($name,$id,$dest,$smsg);
}
#cloned again?
sub cs {
        my ($instr,$time,$dur,@o) = @_;
        my $str = join(" ",("i$instr",(map { sprintf('%0.3f',$_) } ($time,$dur,@o)))).$/;
        return $str;
}
sub new_bug {
    my ($ID) = @_;
    my @instrs = qw(1902 1903);
    return {
        ID => $ID,
        x => 0,
        y => 0,
        r => 1,
        instrument => $instrs[$instr_cnt++ % @instrs],
    }
}
sub get_bug {
    my ($ID) = @_;
    if (!exists $bugs{$ID}) {
        $bugs{$ID} = new_bug($ID);
    }
    return $bugs{$ID};
}
sub filterit {
        my ($self,$name,$id,$dest,$msg) = @_;
        my $arr = from_json($msg);
        shift @$arr;
        my $cnt = 0;
        my @omsg = ();
        for my $elm (@$arr) {
            my $maxloud = 10000.0 / (1+log(1+@$arr));
            my $id = $cnt++;
            next if $id >= 40;
            my $x = $elm->{x};
            my $y = $elm->{y};
            my $v = $elm->{v};
            my $w = $elm->{w};
            my $lastx = $points{$id}->{x};
            my $lasty = $points{$id}->{y};
            $lastx = $x unless defined $lastx;
            $lasty = $y unless defined $lasty;
            $points{$id}->{x} = $x;
            $points{$id}->{y} = $y;
            my $dx = $x - $lastx;
            my $dy = $y - $lasty;
            my $mag = abs($dy) * abs($dx);
            my $i = $id;
            my $dist = sqrt($dx * $dx + $dy * $dy);
            my $maxdist = sqrt(1000*1000 + 1000*1000);
            #warn $dist;
            #my $pitch = 100 + exp(log(4000)*$i/100.0) + exp(log(9000)*(100.0-$reli)/100.0);
            warn "$dist $maxdist $x $y $dx $dy";
            my $loudness = ( $maxloud / 10.0 + $maxloud * 0.01 * $w + $maxloud * 0.01 * $v +  10*$maxloud*$dist / $maxdist ) /$maxloud;
            #my $pitch = 100 + exp(log(1000)*$i/100.0) + exp(log(10000)*$dist/$maxdist) + exp(log(2000)*abs(500-$x)/500.0) + -1000*$v + 1000*$w;
            my $pitch = 40 + 60*$i/30 +  exp(log(2000)*abs(500-$x)/500.0) + exp(log(1000)* $dist / $maxdist);
            my $nmsg = cs("6666",0,0.0001,$i,$loudness, $pitch);
            push @omsg, $nmsg;
        }
        return ($name,$id,$dest,join($/,@omsg));
}


#cloned again?
sub choose { return @_[rand(@_)]; }
#cloned again?
sub min { ($_[0] > $_[1])?$_[1]:$_[0] }
