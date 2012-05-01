use Harbinger;
use IO::File;
use strict;

use constant PI => 3.14159;
my $orc = "csound/ripple-bells.orc";
my $sco = "csound/ripple-bells.sco";
my $handler = "ripple";
my $H = Harbinger->new(port=>30666);
if ($ARGV[0] eq "-print") {
        $H->addHandler($handler,new Harbinger::DebugHandler());
        $H->run;
        exit(0);
}
my $jackit = 1;
$H->addHandler($handler,new
        Harbinger::PipeHandler(
                'open'=>((!$jackit)?"csound -dm6 -L stdin -o devaudio $orc $sco":
		                    "csound -dm6 -+rtaudio=jack  -o devaudio -b 400 -B 2048 -L stdin $orc $sco"),
                autoflush=>1,
                terminator=>$/,
                filter=>\&filterit,
        )
);

$H->run;


my %data = ();
sub filterit {
    my ($self,$name,$id,$dest,$msg) = @_;
    my @args = split(/\s+/,$msg);
    my $rowm = shift @args;
    my %rowmap = (
                  128 => 1,
                  256 => 2,
                  384 => 3,
                 );
    my $instrdurmap = {
                       1 => 1,
                       2 => 1,
                       3 => 10,
                      };
    my $instrument = $rowmap{$rowm} || 1;
    my $durv = $instrdurmap->{$instrument};
    #my $row = shift @args;
    #$row =~ s/\://;
    #$row++;
    #my $old = $data{$row} || [];
    my $n = @args;
    my @out = ();
    warn $n;
    $args[0]=$args[1];# hack
    foreach my $i (0..($n-1)) {
        #if ($old->[$i] != $args[$i]) {
        #    $old->[$i] = $args[$i];
        my $v = $args[$i];
        if (abs($v) > 5 && rand() > 0.9) {
            my $pitch = 40 + exp(log(5000) * $i /(1.0*$n) + $v*rand()/($n));
            my $amp = 30000/128.0 * log(abs($v)) / log($n);
            my $duration = 0.1;
            push @out,csnd($instrument,0.001,$durv*$duration,$amp,$pitch);
        }
        #}
    }
    return ($name,$id,$dest,join($/,@out).$/);
}
sub csnd {
        my ($instr,$time,$dur,@o) = @_;
        my $str = join(" ",("i$instr",(map { sprintf('%0.6f',$_) } ($time,$dur,@o)))).$/;        
        return $str;
}
