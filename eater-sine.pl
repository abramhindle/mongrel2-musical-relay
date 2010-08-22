use Harbinger;
use IO::File;
use strict;

use constant PI => 3.14159;
$|=1;
my $program = "bugs";
my %bugs;
my $instr_cnt=0;
my $maxloud = 16000/100.0;
my $HEIGHT = 10;

my $orc = "csound/sine2.orc";
my $sco = "csound/sine.sco";

my $H = Harbinger->new(port=>30666);
if ($ARGV[0] eq "-print") {
        $H->addHandler( $program ,new Harbinger::DebugHandler());
        $H->run;
        exit(0);
}
my $jackit = 0;
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
    my @msgs = split(/\n/,$msg);
    my $smsg = join($/, map { my $msg=$_; my ($_,$_,$_,$o)=process_line($self, $name, $id, $dest, $msg); $o } @msgs);
    #warn $smsg;
    return ($name,$id,$dest,$smsg);
}

   
sub process_line {
        my ($self,$name,$id,$dest,$msg) = @_;
        my ($command,$bugid,$rest) = split(/\s+/,$msg,3);
        my $bug = get_bug($bugid);
        my $nmsg="";
        my $instrument = $bug->{instrument};#{inschoose(@instrs);#1902;#$instrs[$color % @instrs];
        if ($command eq "Moved") {
            my ($br, $bx,$by,$bdx,$bdy) = split(/\s+/,$rest);
            my $radius = $br;
            my ($x,$y) = ($bx,$by);
            my $xv = $bdx;
            my $yv = $bdy;
            $bug->{r} = $br;
            $bug->{x} = $bx;
            $bug->{y} = $by;
            my $scale = 1920;
            my $sxv = $scale * $xv;
            my $syv = $scale * $yv;
            my $sx = $scale * $x;
            my $sy = $scale * $y;
            my $theta = atan2($xv,$yv);
            my $theta2 = atan2($x,$y);
            my $duration = $radius / 256.0;
            my $loudness = (0.5 * $radius / 256.0  * 100 + $theta + $theta2);
            my $pitch = 20 + abs(240*$y) + abs(320*$x) + 1000 * (1 - $radius/256.0);
            $pitch *= (1.0 + $theta);
            $nmsg = cs("1", 0.001+0.01*rand(), $duration, $loudness, $pitch);
            return ($name,$id,$dest,$nmsg);
        } elsif ($command eq "Eaten") {
            my ($bugid2, $oldradius, $bug2radius,$newradius) = split(/\s+/,$rest);
            my $loudness = 4000 * ($oldradius - $bug2radius);
            my $pitch = 20 + 1000 * (1 - $newradius/256.0);
            my $duration = 0.1 + $newradius / 256.0;
            $nmsg = cs("1", 0.001+0.01*rand(), $duration, $loudness, $pitch);
            return ($name,$id,$dest,$nmsg);
        }
        warn "DID NOT HANDLE: $msg";
        return ($name,$id,$dest,undef);
}



#cloned again?
sub choose { return @_[rand(@_)]; }
#cloned again?
sub min { ($_[0] > $_[1])?$_[1]:$_[0] }
