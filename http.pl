use strict;
use JSON;
use ZeroMQ qw/:all/;

my $sender_id = "82209006-86FF-4982-B5EA-D1E29E55D481";
my $sub_addr = "tcp://127.0.0.1:9997";
my $pub_addr = "tcp://127.0.0.1:9996";

my ($req_socket, $resp_socket, $cxt) = mongrel_init( $sender_id, $sub_addr, $pub_addr );


while(1) {
    print "WAITING FOR REQUEST$/";

    my $req = mongrel_recv( $req_socket );
    
    if (mongrel_is_disconnect( $req )) {
        print "DICONNECT";
        next;
    }
    my $response = sprintf("<pre>\nSENDER: %s\nIDENT:%s\nPATH: %s\nHEADERS:%s\nBODY:%s</pre>",
                           $req->{sender}, 
                           $req->{conn_id},
                           $req->{path}, 
                           to_json($req->{headers}), 
                           $req->{body});

    print $response,$/;

    mongrel_reply_http($resp_socket, $req, $response);
}

# Gee instead of a prefix maybe you should make a module?

sub mongrel_recv {
    my ($req_socket) = @_;
    return mongrel_parse_request( $req_socket->recv() );
}



#ported mongrel2/request.py
sub mongrel_parse_netstring {
    my ($ns) = @_;
    my ($len, $rest) = split(':', $ns, 2);
    $len = int($len);
    substr($rest,$len,1) == ',' or die "Netstring did not end in ','";
    return (substr($rest, 0, $len), substr($rest, $len+1));
}


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

sub mongrel_is_disconnect {
    my ($self) = @_;
    if ($self->{headers}->{METHOD} eq 'JSON') {
        return $self->{data}->{type} eq 'disconnect';
    }
    return 0;
}

#        """
#        Raw send to the given connection ID at the given uuid, mostly used 
#        internally.
#        """

sub mongrel_send {
    my ($resp_socket, $uuid, $conn_id, $msg) = @_;
    my $header = sprintf("%s %d:%s,", $uuid, length($conn_id), $conn_id);
    my $message = $header . ' ' . $msg;
    $resp_socket->send( ZeroMQ::Message->new( $message ) );
}

sub mongrel_reply {
    my ($resp_socket, $req, $msg) = @_;
    mongrel_send( $resp_socket, $req->{sender}, $req->{conn_id}, $msg );
}

#        Basic HTTP response mechanism which will take your body,
#        any headers you've made, and encode them so that the 
#        browser gets them.


sub mongrel_reply_http {
    my ($resp_socket, $req, $body, $code, $status, $headers) = @_;
    $code ||= 200;
    $status ||= "OK";
    $headers ||= {};
    mongrel_reply( $resp_socket, $req, mongrel_http_response($body, $code, $status, $headers));
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

sub mongrel_init {
    my ( $sender_id, $sub_addr, $pub_addr ) = @_;

    my $cxt = ZeroMQ::Context->new;

    my $req_socket = ZeroMQ::Socket->new($cxt, ZMQ_UPSTREAM);
    $req_socket->connect($sub_addr);

    my $resp_socket = ZeroMQ::Socket->new($cxt, ZMQ_PUB);
    $resp_socket->connect($pub_addr);
    $resp_socket->setsockopt( ZMQ_IDENTITY, $sender_id );
    return ( $req_socket, $resp_socket, $cxt );
}
