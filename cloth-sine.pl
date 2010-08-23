use Harbinger;
use IO::File;
use JSON;
use strict;

use constant PI => 3.14159;
$|=1;
my $program = "cloth";
my %bugs;
my $instr_cnt=0;
my $maxloud = 16000/100.0;
my $HEIGHT = 10;

my $orc = "csound/100sine.orc";
my $sco = "csound/100sine.sco";

my $H = Harbinger->new(port=>30666);
if ($ARGV[0] eq "-print") {
        $H->addHandler( $program ,new Harbinger::DebugHandler());
        $H->run;
        exit(0);
}
my $jackit = 1;
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
        my @msgs = split($/,$msg);
        my @omsgs = map {
            my $msg = $_;
            my @v = split(" ",$msg);# from_json($msg);
            my ($w,$h,$x,$y,$j,$k) = @v;
            my $mag = abs($j) * abs($k);
            my $loudness = $maxloud / 10.0;# * $mag / 1000.0;
            my $i = $w + $h * $HEIGHT;
            my $reli = $x * 10 + 100*$y;
            my $pitch = 100 + exp(log(4000)*$i/100.0) + exp(log(9000)*(100.0-$reli)/100.0);
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
