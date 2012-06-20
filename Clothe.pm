package Clothe;
use Harbinger;
use IO::File;
use JSON;
use strict;
#use List::Util qw(min max);
use constant PI => 3.14159;
$|=1;
my $program = "cloth";
my %bugs;
my $instr_cnt=0;
my $maxloud = 16000/100.0;
my $HEIGHT = 10;
my $jackit = $ENV{JACKIT} || 0;
my $orc = "csound/100sine.orc";
my $sco = "csound/100sine.sco";
my %points = ();

sub register {
	my ($H,$jackit) = @_;
	$H->addHandler($program ,new
	        Harbinger::PipeHandler(
	                'open'=>((!$jackit)?"csound -dm6 -L stdin -o devaudio $orc $sco":
			                    "csound -dm6 -+rtaudio=jack -+jack_client=csoundClothe -o devaudio -b 400 -B 2048 -L stdin $orc $sco"),
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
sub escale {
    my ($x) = @_;
    return (exp($x) - 1.0)/(exp(1)-1.0)
}
sub filterit {
        my ($self,$name,$id,$dest,$msg) = @_;
        my @msgs = split($/,$msg);
        my $clientID = shift @msgs;
        chomp($clientID);
        if (@msgs && $msgs[0] =~ /^bell/) {
            my $bell = $msgs[0];
            chomp($bell);
            my ($dur) = ($bell =~ /bell\s+(\d+)\s*$/);
            warn "$bell :: $dur";
            my $duration = 0.01 + escale(max(0, min($dur, 100))/100.0) * 15;
            my $pitch = 20 + $clientID % 10 * 10 + 4000*$duration/15;
            my $loudness = 300+20000 * escale($duration/16.0);
            my $nmsg = cs('"bell"',0.001, $duration, $loudness, $pitch);
            warn $nmsg;
            return ($name,$id,$dest,$nmsg);
        }
        my @omsgs = map {
            my $msg = $_;
            my @v = split(" ",$msg);# from_json($msg);
            my ($w,$h,$x,$y,$j,$k) = @v;
            my $mag = abs($j) * abs($k);

            my $i = $w + $h * $HEIGHT;
            my $lastx = $points{$clientID}->{$i}->{x} || 0;
            my $lasty = $points{$clientID}->{$i}->{y} || 0;
            $points{$clientID}->{$i}->{x} = $x;
            $points{$clientID}->{$i}->{y} = $y;
            my $dx = $x - $lastx;
            my $dy = $y - $lasty;
            my $reli = $x * 10 + 100*$y;
            my $dist = sqrt($dx * $dx + $dy * $dy);
            #warn $dist;
            #my $pitch = 100 + exp(log(4000)*$i/100.0) + exp(log(9000)*(100.0-$reli)/100.0);
            my $loudness = $maxloud / 10.0 + $maxloud*10*$dist;# * $mag / 1000.0;
            my $pitch = 100 + exp(log(1000)*$i/100.0) + exp(log(2000)*(100.0-$reli)/100.0) +
                        exp(log(2000)*10*$dist);
            my $nmsg = cs("666",0,0.0001,$i,$loudness, $pitch);
        } @msgs;
        return ($name,$id,$dest,join($/,@omsgs));
        # shortcut this crap

        # my $h = 0;
        # my @o = ();
        # my $w = 0;
        # my $cnt = 0;
        # #for my $row (@$v) {            
        # #    my $w = 0;
        # #    for my $elm (@$row) {
        # while(@v) {
        #         $w = $cnt % 10;
        #         $h = ($cnt - $w) / 10;
        #         my $x = shift @v;
        #         my $y = shift @v;
        #         my $j = shift @v;
        #         my $k = shift @v;
        #         #my ($x,$y,$j,$k) = map { $elm->{$_} } qw(x y j k);
        #         warn "$x $y $j $k";
        #         my $mag = abs($j) * abs($k);
        #         my $loudness = $maxloud / 10.0;# * $mag / 1000.0;
        #         my $i = $w + $h * $HEIGHT;
        #         my $pitch = 100 + 9000*log(1+$i)/log(101) + 100/2.7*exp($x) + 1000/2.7*exp($y) ;
        # 
        #         push @o, cs("666",0,0.0001,$i,$loudness, $pitch);
        # 
        #         
        #     #}
        #         $h++;
        #         $cnt++;
        # }
        # my $omsg = join($/,@o);
        # #warn "DID NOT HANDLE: $msg";
        # return ($name,$id,$dest,$omsg);
}


#cloned again?
sub choose { return @_[rand(@_)]; }
#cloned again?
sub min { ($_[0] > $_[1])?$_[1]:$_[0] }
sub max { ($_[0] < $_[1])?$_[1]:$_[0] }

1;
