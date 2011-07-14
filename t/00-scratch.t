#!/usr/bin/perl
use strict; use warnings;
use Test::More;

use_ok('Net::SSH::Perl::WithSocks');

my $ssh1 = Net::SSH::Perl::WithSocks->new(
  'motherbrain.nanabox.net',
  with_socks => {
    socks_host => 'motherbrain.nanabox.net',
    socks_port => 9000 } );

$ssh1->login('test', 'test') or fail("\$ssh1->login");


done_testing();
