#!/usr/bin/perl

use CGI;

use IO::Socket qw(AF_INET SOCK_STREAM);

my $q = CGI->new;

$EVE_HOST   = "localhost";
$REDIR_HOST = "localhost";

# CGI script to connect to an Event Display server.
#
# Reports progress as it goes and at the end outputs a link to
# a newly spawned instance.
# And a reminder that a tunnel needs to be made at this point.
#
# Once things more-or-less work, we can just redirect on success:
#   print $q->redirect('http://$REDIR_HOST:$REDIR_PORT/...');
# ... or do some JS magick, or whatever.

# Developmental auto-flush of stdout
$| = 1;

################################################################################

sub cgi_beg
{
  print $q->header('text/html');

  print <<"FNORD";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
        "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <title>Revetor Event-display Gateway</title>
</head>
<body>

FNORD
}

sub cgi_print
{
  print "<p><pre>", join("\n", @_), "</pre>\n";
}

sub cgi_end
{
  print<<"FNORD";

</body>
</html>
FNORD
}

sub cgi_die
{
  print "<p> $_[0]\n";
  cgi_end();
  exit(1);
}

################################################################################

cgi_beg();

# Usage of INET sockets in cgi-bin under SE requires:
#   /usr/sbin/setsebool -P httpd_can_network_connect 1
# Maybe we should use UNIX sockets.

my $client = IO::Socket->new(
    Domain => AF_INET,
    Type => SOCK_STREAM,
    proto => 'tcp',
    PeerPort => 7777,
    PeerHost => $EVE_HOST,
    Timeout => 5
) || cgi_die "Can't open socket: $@";

cgi_print "Connected to 7777";

my $buf;
$client->recv($buf, 1024);
cgi_print "Server greeting: $buf";


cgi_print "Sending Banana -- should send LFN or something";

# MUST include trailing \n, the server is looking for it!

my $size = $client->send("Banana\n");
cgi_print "Sent data of length: $size";

# $client->shutdown(SHUT_WR);

$client->recv($buf, 1024);
cgi_print "Server response: $buf";
chomp $buf;

$client->close();

# Expect hash response, as { 'port'=> , 'dir'=> , 'key'=> }
$resp = eval $buf;

my $URL = "http://${REDIR_HOST}:$resp->{'port'}/$resp->{'dir'}?token=$resp->{'key'}";

# For opening on localhost directly.
# print "xdg-open $URL\n";
# exec  "xdg-open $URL";

print<<"FNORD";
<h2>
Your event display is ready, click link to enter:
</h2>
<p>
<a href="$URL">$URL</a>

<small>
<p>
P.S. You probably need to make a tunnel to port $resp->{'port'} as things stand now.
<p>
ssh -S vocms-ctrl -O forward -L$resp->{'port'}:localhost:$resp->{'port'}  x
</small>
FNORD

cgi_end();
