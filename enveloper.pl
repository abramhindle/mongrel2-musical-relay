use Harbinger;
use IO::File;
use List::Util qw(min max);
use JSON;
use strict;

use constant PI => 3.14159;
my $program = "voronoi";

my $H = Harbinger->new(port=>30666);
my $jackit = 0;

use Enveloper;
Enveloper::register($H, $jackit);

$H->run;


