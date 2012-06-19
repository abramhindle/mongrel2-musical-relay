use Harbinger;
use IO::File;
use List::Util qw(min max);
use JSON;
use strict;


my $H = Harbinger->new(port=>30666);
my $jackit = 0;

use Force;
Force::register($H, $jackit);

$H->run;


