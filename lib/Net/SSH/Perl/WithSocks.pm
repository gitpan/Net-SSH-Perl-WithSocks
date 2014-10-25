package Net::SSH::Perl::WithSocks;
use strict; use warnings;
use base qw(Net::SSH::Perl);

=head1 NAME

Net::SSH::Perl::WithSocks;

=head1 SYNOPSIS

my $ssh = Net::SSH::Perl::WithSocks->new('motherbrain.nanabox.net',
  with_socks => {
    socks_host => 'motherbrain.nanabox.net',
    socks_port => 9000 
  }
);

$ssh->login(); # Use it just like a regular Net::SSH object

=head1 DESCRIPTION

This is a utility to make simple the process of connecting to an SSH host
by way of a TCP proxy, such as those provided by OpenSSH servers for tunneling.
It is based off of Net::SSH::Perl so that it can work in Windows as well, though
the basic idea could be expounded upon to support Net::SSH2 as well.

=cut

use Carp;
use IO::Socket::Socks;

our $VERSION = '0.01';

sub _init {
  my( $self, %params ) = @_;
  if( $params{SocksHost} ) {
    $self->{WithSocks} = {
      ProxyAddr => $params{SocksHost},
      ProxyPort => $params{SocksPort},
    };
  }
  $self->SUPER::_init(%params);
}

sub _connect {
  my $ssh = shift;
  return $ssh->SUPER::_connect(@_) unless $ssh->{WithSocks};

  my( $raddr, $rport );

  $raddr = inet_aton($ssh->{host});
  croak "Net::SSH::Perl::WithSocks: Bad Hostname: $ssh->{host}" unless defined $raddr;
  $rport = $ssh->{config}->get('port') || 'ssh';
  if( $rport =~ /\D/ ) {
    my @serv = getservbyname(my $serv = $rport, 'tcp');
    $rport = $serv[2] || 22;
  }
  $ssh->debug("Connecting to $ssh->{host}:$rport");
  my $sock = IO::Socket::Socks->new(
    ConnectAddr => $raddr,
    ConnectPort => $rport,
    %{$ssh->{WithSocks}} ) or die "Can't connect to $ssh->{host}:$rport : $!";

  select((select($sock), $|=1)[0]);

  $ssh->{session}{sock} = $sock;
  $ssh->_exchange_identification;

  defined( $sock->blocking(0) ) or die "Can't set non-blocking: $!";
  $ssh->debug("Connection established.");
}

1;

__END__

=head1 SEE ALSO

L<Net::SSH::Perl::MultiHop> is a module that can create chains of SSH objects of
any type to connect to servers behind layers of security. It depends heavily on
Net::SSH::Perl::WithSocks to pull off basic one-off hops and requests.

=head1 AUTHOR

Jennie Rose Evers-Corvina C<seven@nanabox.net>, Matthew S Trout

Maintained by Jennie Rose Evers-Corvina. Please send patches, ideas or comments to C<withsocks@sevvie.co>.

=cut
