use strict;
my $first = 1;
my $depth = 0;
my $lastitem = 0;
while(<>) {
	chomp;
	s/  /\t/g;
        $_ = filter_stars($_);
	if (/^\=$/) {
		$depth = processDepth($depth,"");
		print '\end{itemize}',$/;
		$lastitem = 0;
	} elsif (/^\=(.+)$/) {
		$depth = processDepth($depth,"");
		if ($first) {
			$first = 0;
		} else {
			print '\end{itemize}',$/;
		}
		print "\\sslide{$1}$/";
		print "\\begin{itemize}$/";
		$lastitem = 0;
	} elsif (/^(\t*)\s*\*\s*(.*)$/) {
		print STDERR "=====> $_$/";
		$depth = processDepth($depth,$1);
		my $i = $2;
		print ("\t"x$depth);
		print "\\item $i$/";
		$lastitem = 1;
	} else {
		$lastitem = 0;
		print "$_$/";
	}
}
sub processDepth {
	my ($depth,$one) = @_;
	my $length = length($one);
	if ($depth!=$length) {
		if ($depth > $length) {
			my $d = $depth - $length;
			foreach (1..($depth-$length)) {
				print ("\t"x($d - $_));
				print "\\end{itemize}$/";
			}
		} else {
			foreach (1..($length-$depth)) {
				print ("\t"x($depth+$_));
				print "\\item " if ($_ >= 1 && !$lastitem);
				print "\\begin{itemize}$/";
			}
		}
		$depth = $length;
	}
	print STDERR "$depth $length\n";
	return $depth;
}
sub filter_stars {
    my $line = $_[0];
    if ($line =~ /^(\*+)\*/) {
        warn "FILTER $line";
        my $replace = "\t" x (length($1));
        $replace .= "*";
        $line =~ s/^\*+//;
        $line = $replace . $line
    }
    return $line;
}

