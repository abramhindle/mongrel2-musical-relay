my $sender_id = 'f8144414-ad7a-11df-9185'. 
  '-001bfce70aad';
my $sub_addr = "tcp://127.0.0.1:9997";
my $pub_addr = "tcp://127.0.0.1:9996";
my $cxt = ZeroMQ::Context->new;
my $req_socket = ZeroMQ::Socket->new($cxt, 
  ZMQ_UPSTREAM);
$req_socket->connect($sub_addr);
my $resp_socket = ZeroMQ::Socket->new($cxt, 
  ZMQ_PUB);
$resp_socket->connect($pub_addr);
$resp_socket->setsockopt( ZMQ_IDENTITY, 
  $sender_id );
while(my $req = $req_socket->recv) ...
