use Harbinger;
use IO::File;
use List::Util qw(min max);
use JSON;
use strict;

use constant PI => 3.14159;
my $program = "voronoi";

my $H = Harbinger->new(port=>30666);
my $jackit = 1;

use Vornoi;
Vornoi::register($H, $jackit);
use Clothe;
Clothe::register($H, $jackit);
use Bouncey;
Bouncey::register($H, $jackit);
use AnchorString;
AnchorString::register($H, $jackit);

$H->run;


