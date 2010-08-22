package Harbinger;
use strict;
use IO::Socket;
use Socket;
my $MAX_TO_READ = 65535;
sub new {
	my $type = shift;
	$type = ref($type) || $type;
	my %args = @_;
	my $self = { %args };
	bless($self,$type);
	if ($self->{port}) { $self->bindToPort($self->{port}) }
	$self->{handlers} = [];
	return $self;
}
sub addHandler {
	my ($self,$programname,$handler) = @_;
	push @{$self->{handlers}},[$programname,$handler];
}
sub bindToPort {
	my ($self,$server_port) = @_;
	warn $server_port;
	my $server = IO::Socket::INET->new(
		LocalAddr => ($self->{LocalAddr} || "127.0.0.1"),
		#LocalAddr => "192.168.0.242",
		LocalPort => $server_port, Proto => "udp")
    or die "Couldn't be a udp server on port $server_port : $@\n";
	$self->{sock} = $server;
	return $server;
}
sub run {
	my ($self) = @_;
	my $him;
	if (!$self->{sock}) {
		$self->bindToPort(15011);
	}
	my $server = $self->{sock};
	my $datagram;
	while ($him = $server->recv($datagram, $MAX_TO_READ)) {
		#my($port, $ipaddr) = sockaddr_in($server->peername);
		#my $hishost = gethostbyaddr($ipaddr, AF_INET);
		#print "Client $hishost said ``$datagram''\n";
		if ($datagram eq "ping") {
			$server->send("pong");
			next;
		}
		my @list = split(/\|/,$datagram);
		if (scalar @list < 4) {
			@list = split(/\:/,$datagram);
			if (scalar @list < 4) {
				print STDERR "Bad Message: [$datagram]$/";
				next;
			}
		}
		my $programName = shift @list;
		my $id = shift @list;
		my $dest = shift @list;
		my $msg = join("\|",@list);
		#print STDERR "Prog: $programName$/Id: $id$/Dest: $dest$/Msg: <<EOF$/$msg$/EOF$/";
		$self->handle($programName,$id,$dest,$msg);
	} 
}
sub handle {
	my ($self,$programName,$id,$dest,$msg) = @_;
	if ($dest) {
		#if a dest is specified send msg
	}
	my $handled = 0;
	foreach my $handlerStruct (@{$self->{handlers}}) {
		my ($pname,$handler) = @$handlerStruct;
		if ($pname eq $programName) {
			print "."; #"$pname being handled! ".ref($handler)."$/";
			$handler->handleit($programName,$id,$dest,$msg);
			$handled = 1;
		}
	}
	print STDERR "$programName has no handler$/" unless $handled;
}

1;
package Harbinger::Handler;
use strict;
sub new {
	my $type = shift;
	$type = ref($type) || $type;
	my $self = {};
	bless($self,$type);
	my %args = @_;
	while (my ($key,$val) = each %args) {
		$self->{$key} = $val;
	}
	return $self;
}
sub handleit {
	my ($self,$programName,$id,$dest,$msg) = @_;
	($programName,$id,$dest,$msg) = 
		$self->filter($programName,$id,$dest,$msg);
	return $self->handle($programName,$id,$dest,$msg);
}
sub handle {
	my ($self,$programName,$id,$dest,$msg) = @_;
	
}
sub filter {
	my ($self,$programName,$id,$dest,$msg) = @_;
	return ($programName,$id,$dest,$msg) unless defined $self->{filter};
	return &{$self->{filter}}(@_);
}
package Harbinger::DebugHandler;
use strict;
use base qw(Harbinger::Handler);
sub new {
	my $self = shift->SUPER::new(@_);
	return $self;
}
sub handle {
	my ($self,$programName,$id,$dest,$msg) = @_;
	print STDERR $msg,$/;
	#print STDERR "SENDING ",$msg,$self->{terminator},$/;
}


1;
package Harbinger::PipeHandler;
use strict;
use IO::Socket;
use IO::Handle '_IOLBF';

use base qw(Harbinger::Handler);
sub new {
	my $self = shift->SUPER::new(@_);
	if ($self->{'open'}) {
		$self->open($self->{'open'});
	}	
	$self->{terminator} = "" unless defined $self->{terminator};
	return $self;
}
my $fname = "AAAAA";
sub open {
	no strict 'refs';
	my ($self,$open) = @_;
	$| = 1;
	my $fh = $fname++;
	my $op = "|$open";
	#print STDERR "Opeing: $op$/";
	open $fh,"|-",$open;
	my $io = new IO::Handle;
	$io->autoflush($self->{autoflush}||0);
        $io->fdopen(fileno($fh),"w");
	#my $buffer_var;
	#$io->setvbuf($buffer_var, _IOLBF, 16000);

	$self->{fh} = $io;
	#$io->blocking(0);
	$self->{printer} = Harbinger::BufferedOutputer->new();
	$self->{printer}->open($io);
}
sub handle {
	my ($self,$programName,$id,$dest,$msg) = @_;
	$self->{fh}->print($msg,$self->{terminator});
	#print STDERR "SENDING ",$msg,$self->{terminator},$/;
}
package Harbinger::RunHandler;
use strict;
use base qw(Harbinger::Handler);
sub new {
	my $self = shift->SUPER::new(@_);
	return $self;
}
sub handle {
	my ($self,$programName,$id,$dest,$msg) = @_;
	if ($self->{append}) {
		$self->run($self->{run}." ".$msg);
	} else {
		$self->run($self->{run});
	}
}
sub run {
	my ($self,$msg) = @_;
	my $pid = fork();
	if ($pid) { #parent
	} else {
		exec $msg;
	}
}
1;
package Harbinger::BufferedOutputer;
use strict;
use threads;
use Thread::Queue;

sub new {
	my $type = shift;
	$type = ref($type) || $type;
	my $self = {};
	bless($self,$type);
	my %args = @_;
	while (my ($key,$val) = each %args) {
		$self->{$key} = $val;
	}
	return $self;
}
sub open {
	my ($self,$io) = @_;
	$self->{io} = $io;
	$self->{queue} =  Thread::Queue->new;
	my $thread = threads->create(\&run,$self);
	$self->{thread};
}
sub run {
	my ($self) = @_;
	my $msg;
	my $fileno = $self->{io}->fileno;
	my ($nfound,$timeleft);
	while ($msg = $self->{queue}->dequeue) {
		my ($win,$rin,$ein) = ('','','');
		my $wout = '';
		vec($win,$fileno,1) = 1;
		#while (($nfound,$timeleft) = select($rin,$win,$ein,.1) && $nfound < 1) { threads->yeild;}
		#select($rin,$win,$ein,undef);
		$self->{io}->print($msg);
	}
}
sub print {
	my ($self) = shift;
	print STDERR @_;
	$self->{queue}->enqueue( join("",@_));
}
package Harbinger::UDPHandler;
use strict;
use base qw(Harbinger::Handler);
sub new {
	my $self = shift->SUPER::new(@_);
	$self->run;
	return $self;
}
sub handle {
	my ($self,$programName,$id,$dest,$msg) = @_;
	$self->{sock}->send($msg . $self->{terminator});
}
sub run {
	my ($self) = @_;
	if ($self->{run}) {
		my $pid = fork();
		if ($pid) { #parent
		} else {
			exec $self->{run};
		}
	}
	my $sock = IO::Socket::INET->new(
	   Proto    => 'udp',
	   PeerPort => $self->{port}||15011,
	   PeerAddr => $self->{host}||'localhost',
	) or die "Could not create socket: $!\n";
	$self->{sock} = $sock;
}
1;
