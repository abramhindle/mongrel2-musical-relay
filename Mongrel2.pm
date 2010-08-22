package Mongrel2;
# Todo CPAN it
# ported from mongrel2/examples/http.py and 
#             mongrel2/src/*/request.py
#             mongrel2/src/*/handler.py
use strict;
use JSON;
use ZeroMQ qw/:all/;

# Don't call this
sub new {
    my($class) = @_;
    my $self = { };
    bless($self, $class);
    return $self;
}

sub recv {
    my ($self) = @_;
    return mongrel_parse_request( $self->{req_socket}->recv() );
}

#ported mongrel2/request.py
sub mongrel_parse_netstring {
    my ($ns) = @_;
    my ($len, $rest) = split(':', $ns, 2);
    $len = int($len);
    substr($rest,$len,1) == ',' or die "Netstring did not end in ','";
    return (substr($rest, 0, $len), substr($rest, $len+1));
}

# static
sub mongrel_parse_request {
    my ($msg) = @_;
    my $msg = $msg->data;
    my ($sender, $conn_id, $path, $rest) = split(' ',$msg, 4);
    my ($headers, $rest) = mongrel_parse_netstring( $rest );
    my ($body,$_) = mongrel_parse_netstring( $rest );
    $headers = ($headers)?from_json( $headers ):{};
    my $data = {};
    if ($headers->{METHOD} eq 'JSON') {
        $data = from_json( $body );
    }
    return { sender => $sender,
             conn_id => $conn_id,
             path => $path,
             headers => $headers,
             body => $body,
             data => $data,
           };
}

sub is_disconnect {
    my ($self,$req) = @_;
    if ($req->{headers}->{METHOD} eq 'JSON') {
        return $req->{data}->{type} eq 'disconnect';
    }
    return 0;
}

#        """
#        Raw send to the given connection ID at the given uuid, mostly used 
#        internally.
#        """

sub send {
    my ($self, $uuid, $conn_id, $msg) = @_;
    my $header = sprintf("%s %d:%s,", $uuid, length($conn_id), $conn_id);
    my $message = $header . ' ' . $msg;
    $self->{resp_socket}->send( ZeroMQ::Message->new( $message ) );
}

sub reply {
    my ($self, $req, $msg) = @_;
    $self->send( $req->{sender}, $req->{conn_id}, $msg );
}

#        Basic HTTP response mechanism which will take your body,
#        any headers you've made, and encode them so that the 
#        browser gets them.


sub reply_http {
    my ($self, $req, $body, $code, $status, $headers) = @_;
    $code ||= 200;
    $status ||= "OK";
    $headers ||= {};
    $self->reply( $req, mongrel_http_response($body, $code, $status, $headers));
}

sub mongrel_http_response {
    my ($body, $code, $status, $headers)= @_;
    my @http_headers = ('Content-length: '.length($body));
    while (my ($key, $val) = each(%$headers)) {
        push @http_headers, "$key: $val";
    }
    my $http_headers = join("\r\n", @http_headers);
    sprintf("HTTP/1.1 %s %s\r\n%s\r\n\r\n%s", $code, $status, $http_headers, $body);
}

# This is the real constructor
sub mongrel_init {
    my ( $sender_id, $sub_addr, $pub_addr ) = @_;

    my $mongrel = Mongrel2->new();

    my $cxt = ZeroMQ::Context->new;

    my $req_socket = ZeroMQ::Socket->new($cxt, ZMQ_UPSTREAM);
    $req_socket->connect($sub_addr);

    my $resp_socket = ZeroMQ::Socket->new($cxt, ZMQ_PUB);
    $resp_socket->connect($pub_addr);
    $resp_socket->setsockopt( ZMQ_IDENTITY, $sender_id );

    $mongrel->{cxt} = $cxt;
    $mongrel->{req_socket} = $req_socket;
    $mongrel->{resp_socket} = $resp_socket;
    $mongrel->{sub_adrr} = $sub_addr;
    $mongrel->{pub_adrr} = $pub_addr;
    $mongrel->{sender_id} = $sender_id;

    return $mongrel;
}

1;
